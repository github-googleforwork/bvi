#!/usr/bin/python
#
# Copyright 2018 Google Inc.
# !/usr/bin/python
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
# Enhanced by Thomas Cliett

# This file implements HistoricalUpdate, updating BQ tables for a range of dates
# Parameters:
# Sdate: YYYY-MM-DD
# Edate: YYYY-MM-DD
# Level: 1 to 5

import logging
import webapp2
import random
import sys
from datetime import date, timedelta, datetime
from google.appengine.api import taskqueue

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class HistoricalUpdate(webapp2.RequestHandler):
    def get(self):

        def build_queue_url_and_name():
            if Level == 'custom' or len(Level) > 0 and type(int(Level)) is int:
                q_url = '/bq_api?op=custom_update&level=1' + '&dateref=' + dDate \
                    if Level == 'custom' \
                    else '/bq_api?op=update&level=' + str(Level) + '&dateref=' + dDate

                q_name = 'bqUpdateByLevel1' if Level == 'custom' else 'bqUpdateByLevel' + str(Level)

                logging.info('Url and Queue Name build: [{}] [{}] '.format(q_url, q_name))

            return q_url, q_name

        logging.info('Historical update')

        SdDate = self.request.get('Sdate')
        EdDate = self.request.get('Edate')
        Level = self.request.get('Level')


        Start_date = date(int(SdDate.split('-')[0]), int(SdDate.split('-')[1]), int(SdDate.split('-')[2]))
        End_date = date(int(EdDate.split('-')[0]), int(EdDate.split('-')[1]), int(EdDate.split('-')[2]))

        Number_days = abs((Start_date - End_date).days)
        dDate = SdDate
        Iterating_day = Start_date

        n = 0
        while n <= int(Number_days):
            tNow = datetime.now()
            aNumber = tNow.strftime('%S')
            aRandomNumber = random.randint(0, sys.maxsize)
            aNumber = '{aNumber}_{aRandomNumber}'.format(aNumber=aNumber, aRandomNumber=aRandomNumber)

            queue_url, queue_name = build_queue_url_and_name()
            task = taskqueue.add(queue_name=queue_name, name = 'bqHupdate_level_' + str(Level) + '_' + aNumber + '_' + dDate, 
                                 url=queue_url, method='GET')
            self.response.write(
                "Task {}<br/> for level {}.{} enqueued,<br/>ETA {}<hr/>".format(task.name, Level, Iterating_day,
                                                                                task.eta))

            Iterating_day = Iterating_day + timedelta(days=1)
            dDate = Iterating_day.strftime("%Y-%m-%d")
            n += 1

        logging.info('Sent  ' + str(n) + ' days request for Historical Update, Level ' + str(Level))
        self.response.write('Sent  ' + str(n) + ' days request for Historical Update, Level ' + str(Level))

application = webapp2.WSGIApplication([('/historical_update', HistoricalUpdate)], debug=True)
