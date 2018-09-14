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
from bvi_logger import bvi_log
from datetime import date, timedelta, datetime

import yaml

with open('config.yaml', 'r') as cfgymlfile:
    cfg = yaml.load(cfgymlfile)

ERROR_BEGIN = {
    '1': 'first_fail'
}

CHECK_ROW = {
    '1': 'report_date'
}


def get_log_step(step):
    log_step = step
    if cfg['plan'] == 'Business' and step == 'first':
        log_step = 'customer_usage'
    elif cfg['plan'] == 'Enterprise' and step == 'first':
        log_step = 'users_list'
    return log_step


class ExecManager(webapp2.RequestHandler):
    def get(self):
        project_id = cfg['ids']['project_id']

        # getting request parameters
        exec_type = self.request.get('type', 'daily')
        step = self.request.get('step')
        begin_step = self.request.get('begin_step')
        dateref = self.request.get('dateref')
        start_date = self.request.get('Sdate')
        end_date = self.request.get('Edate')
        auto_rerun = self.request.get('auto_rerun', False)

        today = date.today()
        first_day = date(today.year, 1, 1)
        days_in_year = (today - first_day).days
        frequency = cfg['auto_rerun']['frequency']

        if exec_type == 'daily' and step == 'first' and begin_step and days_in_year % frequency == 0:
            # verifying if an error occurred in the last days, only in every 'frequency' days
            logging.info("[auto-rerun] Verifying date to start...")
            bigquery = createBigQueryService(cfg['scopes']['big_query'], 'bigquery', 'v2')
            query = "SELECT MIN(min_date) as first_fail FROM [{}:logs.errors_dashboard]".format(project_id)
            result = fetch_big_query_data(bigquery, project_id, query, 10)
            rows = convert_big_query_result(result, ERROR_BEGIN)

            if len(rows) == 1 and rows[0]['first_fail']:
                # error occurred in a previous day, moving to historical execution to run again from the first error
                exec_type = 'historical'
                start_date = rows[0]['first_fail']
                end_date = dateref
                auto_rerun = True
                logging.info("[auto-rerun] Starting from {}".format(start_date))
            else:
                logging.info("[auto-rerun] Not needed, no errors found in last {} days.".format(
                    cfg['auto_rerun']['days_lookback']))

        log_date = dateref
        if exec_type == 'daily':
            ymlfile_name = 'manager.yaml'
            date_params = '&dateref={}'.format(dateref)
        elif exec_type == 'historical':
            ymlfile_name = 'manager_historical.yaml'
            date_params = '&Sdate={}&Edate={}'.format(start_date, end_date)
            log_date = start_date
        with open(ymlfile_name, 'r') as mgrymlfile:
            mgr = yaml.load(mgrymlfile)

        if step == 'first' and begin_step:
            bvi_log(date=log_date, resource='exec_manager', message_id='start',
                    message='Start of BVI {} execution'.format(exec_type))

        exec_manager_queue = cfg['queues']['exec_manager']
        queues_to_monitor = mgr[step].get('queues')

        if begin_step:
            bvi_log(date=log_date, resource=get_log_step(step), message_id='start',
                    message='Start of {} step'.format(get_log_step(step)))

            endpoint = mgr[step]['endpoint'] \
                .replace('from_cron', dateref) \
                .replace('start_date', start_date) \
                .replace('end_date', end_date)
            taskqueue.add(queue_name=exec_manager_queue, url=endpoint, method='GET')
            # wait for tasks to be created in the queue
            time.sleep(15)

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

        if count_tasks > 0:
            # Still executing tasks, just continue to monitor queues every 10 seconds
            taskqueue.add(queue_name=exec_manager_queue,
                          url='/exec_manager?type={}{}&step={}&auto_rerun={}'.format(
                              exec_type, date_params, step, auto_rerun),
                          method='GET', countdown=10)
        elif count_tasks == 0 and mgr[step]['next_step']:
            # Tasks finished

            if auto_rerun and 'missing_data_table' in mgr[step]:
                # Check if the rerun was successful
                logging.info("[auto-rerun] Checking for effectiveness...")
                lookback_date_obj = date.today() - timedelta(days=cfg['auto_rerun']['days_lookback'])
                lookback_date = lookback_date_obj.strftime("%Y-%m-%d")
                bigquery = createBigQueryService(cfg['scopes']['big_query'], 'bigquery', 'v2')
                check_query = "SELECT MIN(report_date) AS report_date FROM [{}:{}] " \
                              "WHERE report_date > \'{}\'".format(project_id,
                                                                  mgr[step]['missing_data_table'],
                                                                  lookback_date)
                check_result = fetch_big_query_data(bigquery, project_id, check_query, 10)
                if 'rows' in check_result:
                    check_rows = convert_big_query_result(check_result, CHECK_ROW)
                    if len(check_rows) == 1 and check_rows[0]['report_date']:
                        min_error_date = check_rows[0]['report_date']
                        min_error_date_obj = datetime.strptime(min_error_date, "%Y-%m-%d").date()
                        start_date_obj = datetime.strptime(start_date, "%Y-%m-%d").date()
                        if min_error_date_obj > start_date_obj:
                            logging.info(
                                "[auto-rerun] Min error date for '{}' is greater than start_date, \
                                auto rerun should proceed.".format(
                                    mgr[step]['missing_data_table']))
                        else:
                            logging.info("[auto-rerun] Could not fix any missing data for '{}'. \
                                            Reverting to daily ({}) execution.".format(
                                mgr[step]['missing_data_table'],
                                end_date))
                            exec_type = 'daily'
                            date_params = '&dateref={}'.format(end_date)
                    else:
                        logging.info(
                            "[auto-rerun] No missing data for '{}', auto rerun should proceed.".format(
                                mgr[step]['missing_data_table']))
                else:
                    logging.info(
                        "[auto-rerun] No missing data for '{}', auto rerun should proceed.".format(
                            mgr[step]['missing_data_table']))
                logging.info("[auto-rerun] Finished checking for effectiveness.")

            # Execute next step
            bvi_log(date=log_date, resource=get_log_step(step), message_id='end',
                    message='End of {} step'.format(get_log_step(step)))
            taskqueue.add(queue_name=exec_manager_queue,
                      url='/exec_manager?type={}{}&step={}&begin_step=True&auto_rerun={}'.format(
                          exec_type, date_params, mgr[step]['next_step'], auto_rerun),
                      method='GET')
        else:
            # All tasks finished
            bvi_log(date=log_date, resource='exec_manager', message_id='end',
                    message='End of BVI {} execution'.format(exec_type))


application = webapp2.WSGIApplication([('/exec_manager', ExecManager)], debug=True)
