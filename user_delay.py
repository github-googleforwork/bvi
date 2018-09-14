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

# Author: Thomas Cliett
# Author: Ismael Yuste

# This file implements PartitionPrintUsers, launching one_user_usage_page for a given page token and date

import logging
import webapp2
import random
import sys
from main import returnUsersListToken
from datetime import datetime
from google.appengine.api import taskqueue

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PartitionPrintUsers(webapp2.RequestHandler):
    def get(self):

        pages = 0
        dDate = self.request.get('date')
        page_token = self.request.get('token')
        domain = self.request.get('domain')
        maxPages = self.request.get('maxPages')
        maxPages = int(maxPages)
        numQueues = 3
        queue_name = []
        for x in range(1, numQueues + 1):
            queue_name.append(cfg['queues']['user'] + str(x))

        for pages_token in returnUsersListToken(domain, cfg['credentials']['general'],
                                                cfg['super_admin']['delegated'], page_token):
            if not pages_token:
                break
            pages += 1
            logging.info('User list pages for {} - {} / page {} so far until now'.format(dDate, domain, pages))

            tNow = datetime.now()
            aNumber = tNow.strftime("%S")
            aRandomNumber = random.randint(0, sys.maxsize)
            aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)

            qA = random.randint(0, numQueues - 1)
            taskqueue.add(queue_name=queue_name[qA], name='opul' + dDate + '_' + str(pages) + '_' + aNumber,
                          url='/one_page_user_list?token=' + pages_token + '&date=' + dDate, method='GET')

            if pages >= maxPages:
                taskqueue.add(queue_name=queue_name[qA], name='ud' + dDate + '_' + aNumber,
                              url='/user_delay?token=' + pages_token + '&date=' + dDate
                                  + '&maxPages=' + str(maxPages), method='GET')
                break

        logging.info('User list pages for {} - {} / finally {} pages '.format(dDate, domain, pages))
        self.response.write("User Usage for {} - {} / {} pages".format(dDate, domain, pages))


application = webapp2.WSGIApplication([('/user_delay', PartitionPrintUsers)],
                                      debug=True)