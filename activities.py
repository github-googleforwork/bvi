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
from main import delete_table_big_query, get_dateref_or_from_cron
from datetime import datetime
from google.appengine.api import taskqueue

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintActivities(webapp2.RequestHandler):
    def get(self):
        logging.info('Activities')

        dateref = self.request.get('date', "from_cron")
        if len(dateref) > 0:
            try:
                dateref = get_dateref_or_from_cron(dateref)
            except ValueError:
                logging.error("Wrong updating date = {dateref}".format(dateref=dateref))
                self.response.write("Wrong updating date = {}".format(dateref))
                return

        decoratorDate = "".join(dateref.split("-"))
        # delete table if it exists to avoid data duplication
        delete_table_big_query('audit_log${decoratorDate}'.format(decoratorDate=decoratorDate))

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


application = webapp2.WSGIApplication([('/activities', PrintActivities)], debug=True)
