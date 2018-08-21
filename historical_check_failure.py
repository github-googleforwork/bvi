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


import logging
import webapp2
import random
import sys
from datetime import date, timedelta, datetime
from google.appengine.api import taskqueue

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class HistoricalCheckFailure(webapp2.RequestHandler):
    def get(self):

        logging.info('Historical Check Failure')

        SdDate = self.request.get('Sdate')
        EdDate = self.request.get('Edate')

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

            queue_url = '/exec_check_failure?dateref=' + Iterating_day.strftime("%Y-%m-%d")
            queue_name = cfg['queues']['check_failure']

            task = taskqueue.add(queue_name=queue_name, name='check_failure_' + aNumber + '_' + dDate,
                                 url=queue_url, method='GET')
            self.response.write(
                "Task {}<br/> for exec_check_failure.{} enqueued,<br/>ETA {}<hr/>".format(task.name, Iterating_day,
                                                                                task.eta))

            Iterating_day = Iterating_day + timedelta(days=1)
            dDate = Iterating_day.strftime("%Y-%m-%d")
            n += 1

        logging.info('Sent  ' + str(n) + ' days request for Historical Check Failure')
        self.response.write('Sent  ' + str(n) + ' days request for Historical Check Failure')

application = webapp2.WSGIApplication([('/historical_check_failure', HistoricalCheckFailure)], debug=True)
