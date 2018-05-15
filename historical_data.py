#!/usr/bin/python
#
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Ismael Yuste
# Enhanced by Julio Quinteros
# Enhanced by Thomas Cliett

# This file implements CreateHistoricalData, creating a user_bucket_date for a given date and report
# Parameters:
# report: user, activities, customer
# Sdate: YYYY-MM-DD
# Edate: YYYY-MM-DD
# collection: calendar|drive|groups|login|mobile|token
#

import logging
import webapp2
import random
import sys
from datetime import date, timedelta, datetime
from google.appengine.api import taskqueue

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class CreateHistoricalData(webapp2.RequestHandler):
    def get(self):
        logging.info('Create Historical data')

        queue_name = cfg['queues']['slow']

        report_type = self.request.get('report')
        SdDate = self.request.get('Sdate')
        EdDate = self.request.get('Edate')

        Start_date = date(int(SdDate.split('-')[0]), int(SdDate.split('-')[1]), int(SdDate.split('-')[2]))
        End_date = date(int(EdDate.split('-')[0]), int(EdDate.split('-')[1]), int(EdDate.split('-')[2]))

        # Customer Usage day -4
        today = date.today()
        today_4 = today - timedelta(days=4)

        if Start_date > today_4:
            self.response.write('Error: Start Date > Today - 4 days, try another Start Date')
            logging.info('Error: Start Date > Today - 4 days, try another Start Date')
            return
        if End_date > today_4:
            self.response.write('Error: End Date > Today - 4 days, try another End Date')
            logging.info('Error: End Date > Today - 4 days, try another End Date')
            return

        Number_days = abs((Start_date - End_date).days)
        dDate = SdDate
        iterating_day = Start_date

        n = 0
        while n <= int(Number_days):
            tNow = datetime.now()
            aNumber = tNow.strftime("%S")
            aRandomNumber = random.randint(0, sys.maxsize)
            aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)

            url_report = ''

            if report_type == 'activities':
                url_report = '/activities?date=' + dDate
            elif report_type == 'customer':
                url_report = '/customer?date=' + dDate
            elif report_type == 'user':
                url_report = '/user_usage?date=' + dDate

            logging.info(url_report)

            taskqueue.add(queue_name=queue_name,
                          name='HIS_' + report_type + '_' + dDate + '_' + aNumber,
                          url=url_report, method='GET')
            iterating_day = iterating_day + timedelta(days=1)
            dDate = iterating_day.strftime("%Y-%m-%d")
            n += 1

        logging.info('Sent  ' + str(n) + ' days request for ' + report_type)

        self.response.write('Sent  ' + str(n) + ' days request for ' + report_type)
        self.response.write(' / Starting ' + SdDate + ' ending ' + EdDate)


application = webapp2.WSGIApplication([('/historical_data', CreateHistoricalData)],
                                      debug=True)