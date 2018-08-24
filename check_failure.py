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
#
# This file implements the check failure endpoint. It creates a exec_check_failure task in the queue that
# sends an email if the daily execution has failed.

import logging
import webapp2

from google.appengine.api import taskqueue
from datetime import date
from main import get_dateref_or_from_cron

import yaml
with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class EmailSender(webapp2.RequestHandler):
    def get(self):
        logging.info('Job to send email to admins in case of any failure')

        dateref = self.request.get('dateref', 'from_cron')
        today = date.today()
        try:
            dateref = get_dateref_or_from_cron(dateref)
        except ValueError:
            logging.error('Wrong updating date = {}'.format(dateref))
            self.response.write('Wrong updating date = {}'.format(dateref))
            return

        day = today.strftime("%Y-%m-%d")
        logging.info('Checking the processes for [{}]'.format(day))

        queue_name = cfg['queues']['check_failure']

        taskqueue.add(queue_name=queue_name,
                      url='/exec_check_failure?dateref=' + dateref,
                      method='GET')


application = webapp2.WSGIApplication([('/check_failure', EmailSender)],
                                      debug=True)

