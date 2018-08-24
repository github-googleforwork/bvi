#!/usr/bin/python
#
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import logging
import webapp2
import time
from google.appengine.api import taskqueue
from bigquery_api import fetch_big_query_data, convert_big_query_result
from main import createBigQueryService

import yaml

with open('config.yaml', 'r') as cfgymlfile:
    cfg = yaml.load(cfgymlfile)

ERROR_BEGIN = {
    '1': 'first_fail'
}

class ExecManager(webapp2.RequestHandler):
    def get(self):

        exec_type = self.request.get('type', 'daily')
        logging.info('EXEC_MANAGER --- type: {}'.format(exec_type))

        # getting request parameters
        step = self.request.get('step')
        begin_step = self.request.get('begin_step')
        dateref = self.request.get('dateref')
        start_date = self.request.get('Sdate')
        end_date = self.request.get('Edate')

        # verifying if an error occurred in the previous 10 days
        scopes = cfg['scopes']['big_query']
        project_id = cfg['ids']['project_id']
        bigquery = createBigQueryService(scopes, 'bigquery', 'v2')
        query = "SELECT MIN(min_date) as first_fail FROM [{}:raw_data.errors_dashboard]".format(project_id)
        result = fetch_big_query_data(bigquery, project_id, query, 10)
        rows = convert_big_query_result(result, ERROR_BEGIN)

        if len(rows) == 1 and rows[0]['first_fail'] and exec_type == 'daily':
            # error occurred in a previous day, moving to historical execution to run again from the first error
            exec_type = 'historical'
            start_date = rows[0]['first_fail']
            end_date = dateref

        if exec_type == 'daily':
            ymlfile_name = 'manager.yaml'
        elif exec_type == 'historical':
            ymlfile_name = 'manager_historical.yaml'
        with open(ymlfile_name, 'r') as mgrymlfile:
            mgr = yaml.load(mgrymlfile)

        exec_manager_queue = cfg['queues']['exec_manager']
        queues_to_monitor = mgr[step].get('queues')

        logging.info('EXEC_MANAGER --- step: {}'.format(step))
        logging.info('EXEC_MANAGER --- begin_step: {}'.format(begin_step))
        logging.info('EXEC_MANAGER --- dateref: {}'.format(dateref))

        if begin_step:
            endpoint = mgr[step]['endpoint'] \
                .replace('from_cron', dateref) \
                .replace('start_date', start_date) \
                .replace('end_date', end_date)
            taskqueue.add(queue_name=exec_manager_queue, url=endpoint, method='GET')
            # wait for tasks to be created in the queue
            time.sleep(60)

        count_tasks = 0
        if queues_to_monitor:
            queues_array = queues_to_monitor.split(',')
            stats_list = taskqueue.QueueStatistics.fetch(queues_array)
            for queue_stats in stats_list:
                if queue_stats.tasks:
                    count_tasks += queue_stats.tasks
                if queue_stats.executed_last_minute:
                    count_tasks += queue_stats.executed_last_minute
                if queue_stats.in_flight:
                    count_tasks += queue_stats.in_flight

        logging.info('EXEC_MANAGER --- count_tasks: {}'.format(count_tasks))
        logging.info('EXEC_MANAGER --- step: {}'.format(step))
        logging.info('EXEC_MANAGER --- next step: {}'.format(mgr[step]['next_step']))

        if exec_type == 'daily':
            date_params = '&dateref=' + dateref
        elif exec_type == 'historical':
            date_params = '&Sdate=' + start_date + '&Edate=' + end_date

        if count_tasks > 0:
            # Still executing tasks, just monitor the queues
            taskqueue.add(queue_name=exec_manager_queue,
                          url='/exec_manager?type=' + exec_type + date_params + '&step=' + step,
                          method='GET', countdown=60)
        elif count_tasks == 0 and mgr[step]['next_step']:
            # Tasks finished, execute next step
            taskqueue.add(queue_name=exec_manager_queue,
                          url='/exec_manager?type=' + exec_type + date_params + '&step='
                              + mgr[step]['next_step'] + '&begin_step=True',
                          method='GET')


application = webapp2.WSGIApplication([('/exec_manager', ExecManager)], debug=True)