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

# This file implements PrintUsers, launching one_user_usage_page for a given page token and date

import logging
import webapp2
import random
import sys
from main import delete_table_big_query
from datetime import date, datetime
from google.appengine.api import taskqueue
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintUsers(webapp2.RequestHandler):
    def get(self):
        # User List today
        today = date.today()
        dDate = today.strftime("%Y-%m-%d")

        if cfg['plan'] == 'Enterprise':
            bvi_log(date=dDate, resource='exec', message_id='start', message='Start of BVI daily execution')
        bvi_log(date=dDate, resource='users_list', message_id='start', message='Start of /user call')

        page_token = ''
        maxPages = cfg['task_management']['max_pages']
        queue_name = cfg['queues']['user'] + str(1)

        decoratorDate = "".join(dDate.split("-"))
        # delete table if it exists to avoid data duplication
        delete_table_big_query('users_list_date${decoratorDate}'.format(decoratorDate=decoratorDate))

        domains = list(set(cfg['domains'].split(";")))
        for domain in domains:
            domain = domain.strip()
            tNow = datetime.now()
            aNumber = tNow.strftime("%S")
            aRandomNumber = random.randint(0, sys.maxsize)
            aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)

            #1st page for user
            taskqueue.add(queue_name=queue_name, name='opul' + dDate + '_' + str(maxPages) + '_' + aNumber,
                          url='/one_page_user_list?token=&date=' + dDate + '&domain=' + domain, method='GET')

            #Starts user delay with token empty for 2nd page
            taskqueue.add(queue_name=queue_name, name='ud' + dDate + '_' + aNumber,
                          url='/user_delay?token=' + page_token + '&domain=' + domain + '&maxPages=' + str(maxPages),
                          method='GET')

        logging.info('User list main for {} - {} / max pages {}'.format(dDate, cfg['domains'], maxPages))
        self.response.write('User list main for {} - {} / max pages {}'.format(dDate, cfg['domains'], maxPages))

        bvi_log(date=dDate, resource='users_list', message_id='end', message='end of /user call')


application = webapp2.WSGIApplication([('/user', PrintUsers)],
                                      debug=True)