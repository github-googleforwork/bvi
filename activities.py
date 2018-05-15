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

# This file implements PrintActivities, launching activities_app

import logging
import webapp2
import random
import sys
from datetime import date, timedelta, datetime
from google.appengine.api import taskqueue
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintActivities(webapp2.RequestHandler):
    def get(self):
        logging.info('Activities')

        dateref = self.request.get('date', "from_cron")
        if len(dateref) > 0:
            try:
                if dateref == "from_cron":
                    # Customer Usage day -4 from February 2018
                    today = date.today()
                    today_4 = today - timedelta(days=4)
                    dateref = today_4.strftime("%Y-%m-%d")

            except ValueError:
                logging.error("Wrong updating date = {dateref}".format(dateref=dateref))
                self.response.write("Wrong updating date = {}".format(dateref))
                return

        bvi_log(date=dateref, resource='activities', message_id='start', message='Start of /activities call')

        collection = 'admin|drive|calendar|gplus'
        collection = list(set(collection.split("|")))
        queue_name = cfg['queues']['slow']

        tNow = datetime.now()
        aNumber = tNow.strftime("%S")
        aRandomNumber = random.randint(0, sys.maxsize)
        aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)

        processed = 0

        for app in collection:
            taskqueue.add(queue_name=queue_name,
                          name='act' + dateref + '_' + app + '_' + aNumber,
                          url='/activities_app?app=' + app + '&date=' + dateref, method='GET')
            processed += 1

        logging.info('Activities for {} - {} / finally {} apps '.format(dateref, cfg['domains'], processed))
        self.response.write("Activities for {} - {} / finally {} apps".format(dateref, cfg['domains'], processed))

        bvi_log(date=dateref, resource='activities', message_id='end', message='End of /activities call')

application = webapp2.WSGIApplication([('/activities', PrintActivities)], debug=True)
