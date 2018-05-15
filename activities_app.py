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
# Author: Thomas Cliett

# This file implements PrintActivitiesApp, launching one_page_activities
# Parameters:
# app: admin|calendar|drive|groups|login|mobile|token
# date: YYYY-MM-DD

import logging
import webapp2
import random
import sys
from datetime import datetime
from google.appengine.api import taskqueue
from main import returnActivitiesToken
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintActivitiesApp(webapp2.RequestHandler):
    def get(self):
        logging.info('Activities')

        appName = self.request.get('app')
        dateref = self.request.get('date')

        bvi_log(date=dateref, resource='activities', message_id='start_app', message='Start of /activities_app call')
        try:
            pages = 0
            page_token = self.request.get('token')
            maxPages = cfg['task_management']['max_pages']
            maxPages = int(maxPages)
            numQueues = 5
            queue_name = []
            for x in range(1, numQueues + 1):
                queue_name.append(cfg['queues']['activities'] + str(x))

            tNow = datetime.now()
            aNumber = tNow.strftime("%S")
            aRandomNumber = random.randint(0, sys.maxsize)
            aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)

            # 1st page for activities
            if not page_token:
                taskqueue.add(queue_name=queue_name[1],
                              name='apua_1_' + appName + '_' + dateref + '_' + aNumber,
                              url='/one_page_user_activities?token=&date=' + dateref + '&app=' + appName,
                              method='GET')

            for pages_token in returnActivitiesToken(dateref, appName, cfg['credentials']['general'],
                                                     cfg['super_admin']['delegated'], page_token):
                if not pages_token:
                    break
                pages += 1
                logging.info('Pages {} of maxPages {}'.format)
                logging.info('Activities pages for {} - {} / page {} so far until now'.format(dateref, appName, pages))

                tNow = datetime.now()
                aNumber = tNow.strftime("%S")
                aRandomNumber = random.randint(0, sys.maxsize)
                aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)
                qA = random.randint(0, numQueues - 1)

                taskqueue.add(queue_name=queue_name[qA],
                              name='apua_' + appName + '_' + dateref + '_' + str(pages) + '_' + aNumber,
                              url='/one_page_user_activities?token=' + pages_token + '&date=' + dateref + '&app=' + appName,
                              method='GET')

                if pages >= maxPages:
                    taskqueue.add(queue_name=queue_name[qA],
                                  name='act' + dateref + '_' + appName + '_' + aNumber,
                                  url='/activities_app?token=' + pages_token + '&app=' + appName + '&date=' + dateref,
                                  method='GET')
                    break

            logging.info('User Usage pages for {} - {} / finally {} pages '.format(dateref, appName, pages))
            self.response.write("User Usage for {} - {} / {} pages".format(dateref, appName, pages))
        except Exception as err:
            logging.error(err)
            self.response.write('Activities for ' + dateref + ' - ' + cfg['domains'] + ': ERROR')
            raise err

        bvi_log(date=dateref, resource='activities', message_id='end_app', message='End of /activities_app call')


application = webapp2.WSGIApplication([('/activities_app', PrintActivitiesApp)],
                                      debug=True)
