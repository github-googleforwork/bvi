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
from google.appengine.api import taskqueue
from datetime import date, timedelta

import yaml

with open('config.yaml', 'r') as cfgymlfile:
    cfg = yaml.load(cfgymlfile)


class Run(webapp2.RequestHandler):
    def get(self):

        exec_type = self.request.get('type', 'daily')
        dateref = self.request.get('dateref', 'from_cron')
        start_date = self.request.get('Sdate')
        end_date = self.request.get('Edate')
        if exec_type == 'daily' and len(dateref) > 0:
            try:
                if dateref == 'from_cron':
                    # [today - 4]
                    today = date.today()
                    today_4 = today - timedelta(days=4)
                    dateref = today_4.strftime('%Y-%m-%d')

            except ValueError:
                logging.error('Wrong updating date = {}'.format(dateref))
                self.response.write('Wrong updating date = {}'.format(dateref))
                return

            taskqueue.add(queue_name=cfg['queues']['exec_manager'],
                          url='/exec_manager?type=' + exec_type + '&dateref=' + dateref + '&step=first&begin_step=True',
                          method='GET')
        elif exec_type == 'historical' and len(start_date) > 0 and len(end_date) > 0:
            taskqueue.add(queue_name=cfg['queues']['exec_manager'],
                          url='/exec_manager?type=' + exec_type + '&Sdate=' + start_date + '&Edate=' + end_date
                              + '&step=first&begin_step=True',
                          method='GET')

        self.response.write("BVI Run '{}'".format(exec_type))
        if exec_type == 'daily':
            self.response.write("<br/>Date: {}".format(dateref))
        elif exec_type == 'historical':
            self.response.write("<br/>Start date: {}".format(start_date))
            self.response.write("<br/>End date: {}".format(end_date))


application = webapp2.WSGIApplication([('/run', Run)], debug=True)
