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


def count_queued_tasks(queues_to_monitor):
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
    
    return count_tasks


def should_check_for_auto_recover():
    if 'auto_recover' in cfg and 'frequency' in cfg['auto_recover']:
        frequency = cfg['auto_recover']['frequency']
        if frequency:
            today = date.today()
            first_day = date(today.year, 1, 1)
            days_in_year = (today - first_day).days
            
            return days_in_year % frequency == 0
        else:
            return False
    

def get_manager_for_exec_type(exec_type):
    if exec_type == 'daily':
        ymlfile_name = 'manager.yaml'
    elif exec_type == 'historical':
        ymlfile_name = 'manager_historical.yaml'
    with open(ymlfile_name, 'r') as mgrymlfile:
        mgr = yaml.load(mgrymlfile)
        
    return mgr


def exec_historical(mgr, step, SdDate, EdDate):
    logging.info('Create Historical data')

    start_date = date(int(SdDate.split('-')[0]), int(SdDate.split('-')[1]), int(SdDate.split('-')[2]))
    end_date = date(int(EdDate.split('-')[0]), int(EdDate.split('-')[1]), int(EdDate.split('-')[2]))

    today = date.today()
    today_4 = today - timedelta(days=4)
    if start_date > today_4:
        logging.info('Error: Start Date > Today - 4 days, try another Start Date')
        return
    if end_date > today_4:
        logging.info('Error: End Date > Today - 4 days, try another End Date')
        return

    Number_days = abs((start_date - end_date).days)
    dDate = SdDate
    iterating_day = start_date

    n = 0
    while n <= int(Number_days):
        bvi_log(date=dDate, resource=get_log_step(step), message_id='start',
                message='Start of {} step'.format(step))
        endpoint = mgr[step]['endpoint'].replace('from_cron', dDate)
        logging.info(endpoint)
        taskqueue.add(queue_name=cfg['queues']['slow'], url=endpoint, method='GET')

        iterating_day = iterating_day + timedelta(days=1)
        dDate = iterating_day.strftime("%Y-%m-%d")
        n += 1

    logging.info('Sent  ' + str(n) + ' days request for ' + step)


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
        auto_recover = self.request.get('auto_recover', False)
        enable_auto_recover = self.request.get('enable_auto_recover', True)

        if should_check_for_auto_recover() and enable_auto_recover and exec_type == 'daily' \
                and step == 'first' and begin_step:
            # verifying if an error occurred in the last days, only in every 'frequency' days
            logging.info("[auto-recover] Verifying need to execute auto-recover...")
            bigquery = createBigQueryService(cfg['scopes']['big_query'], 'bigquery', 'v2')
            query = "SELECT MIN(min_date) as first_fail FROM [{}:logs.errors_dashboard]".format(project_id)
            result = fetch_big_query_data(bigquery, project_id, query, 10)
            rows = convert_big_query_result(result, ERROR_BEGIN)

            if len(rows) == 1 and rows[0]['first_fail']:
                exec_type = 'historical'
                start_date = rows[0]['first_fail']
                end_date = dateref
                auto_recover = True
                logging.info("[auto-recover] Error occurred in a previous day, moving to historical execution to run \
                again since the first failed execution date. \
                auto-recover starting from {}".format(start_date))
            else:
                logging.info("[auto-recover] Not needed, no errors found in last {} days.".format(
                    cfg['auto_recover']['days_lookback']))

        log_date = dateref
        if exec_type == 'daily':
            date_params = '&dateref={}&enable_auto_recover={}'.format(dateref, str(enable_auto_recover))
        elif exec_type == 'historical':
            date_params = '&Sdate={}&Edate={}&enable_auto_recover={}'.format(start_date,
                                                                              end_date, str(enable_auto_recover))
            log_date = start_date

        if step == 'first' and begin_step:
            bvi_log(date=log_date, resource='exec_manager', message_id='start',
                    message='Start of BVI {} execution'.format(exec_type))

        with open('manager.yaml', 'r') as mgrymlfile:
            mgr = yaml.load(mgrymlfile)
        exec_manager_queue = cfg['queues']['exec_manager']

        if begin_step:
            if exec_type == 'daily':
                bvi_log(date=log_date, resource=get_log_step(step), message_id='start',
                        message='Start of {} step'.format(step))
                endpoint = mgr[step]['endpoint'].replace('from_cron', dateref)
                taskqueue.add(queue_name=exec_manager_queue, url=endpoint, method='GET')
            elif exec_type == 'historical':
                exec_historical(mgr, step, start_date, end_date)

            # wait for tasks to be created in the queue
            time.sleep(15)

        count_tasks = count_queued_tasks(mgr[step].get('queues'))
        if count_tasks == 0 and 'next_step' in mgr[step] and mgr[step]['next_step']:
            # Finished all tasks from this step

            if auto_recover and 'missing_data_table' in mgr[step]:
                # Check if the auto-recover was successful
                logging.info("[auto-recover] Checking for effectiveness...")
                lookback_date_obj = date.today() - timedelta(days=cfg['auto_recover']['days_lookback'])
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
                                "[auto-recover] Min error date for '{}' is greater than start_date, \
                                auto-recover should proceed.".format(
                                    mgr[step]['missing_data_table']))
                        else:
                            logging.info("[auto-recover] Could not fix any missing data for '{}'. \
                            Reverting to daily ({}) execution.".format(
                                mgr[step]['missing_data_table'],
                                end_date))
                            exec_type = 'daily'
                            date_params = '&dateref={}'.format(end_date)
                    else:
                        logging.info(
                            "[auto-recover] No missing data for '{}', auto-recover should proceed.".format(
                                mgr[step]['missing_data_table']))
                else:
                    logging.info(
                        "[auto-recover] No missing data for '{}', auto-recover should proceed.".format(
                            mgr[step]['missing_data_table']))
                logging.info("[auto-recover] Finished checking for effectiveness.")

            # Execute next step
            bvi_log(date=log_date, resource=get_log_step(step), message_id='end',
                    message='End of {} step'.format(get_log_step(step)))
            taskqueue.add(queue_name=exec_manager_queue,
                          url='/exec_manager?type={}{}&step={}&begin_step=True&auto_recover={}'.format(
                              exec_type, date_params, mgr[step]['next_step'], auto_recover),
                          method='GET')
        
        elif count_tasks > 0:
            # Still executing tasks, just schedule to monitor task queues again 10 seconds later
            logging.info("Waiting for tasks to finish...")
            taskqueue.add(queue_name=exec_manager_queue,
                          url='/exec_manager?type={}{}&step={}&auto_recover={}'.format(
                              exec_type, date_params, step, auto_recover),
                          method='GET', countdown=10)
        
        else:
            # Finished ALL tasks
            bvi_log(date=log_date, resource='exec_manager', message_id='end',
                    message='End of BVI {} execution'.format(exec_type))


application = webapp2.WSGIApplication([('/exec_manager', ExecManager)], debug=True)
