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

# This file implements PrintUserUsage, launching one_page_user_usage request
# parameters:
# date: YYYY-MM-DD

import logging
import webapp2
import random
import sys
from datetime import date, timedelta, datetime
from google.appengine.api import taskqueue
from main import returnUserUsageToken, delete_table_big_query
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintUserUsage(webapp2.RequestHandler):
    def get(self):
        logging.info('User Usage')

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

        try:
            pages = 0
            page_token = self.request.get('token')

            if not page_token:
                bvi_log(date=dateref, resource='user_usage', message_id='start', message='Start of /user_usage call')
                decoratorDate = "".join(dateref.split("-"))
                # delete table if it exists to avoid data duplication
                delete_table_big_query('user_usage${decoratorDate}'.format(decoratorDate=decoratorDate))

            maxPages = cfg['task_management']['max_pages']
            maxPages = int(maxPages)
            numQueues = 5
            queue_name = []
            for x in range(1, numQueues + 1):
                queue_name.append(cfg['queues']['user_usage'] + str(x))

            tNow = datetime.now()
            aNumber = tNow.strftime("%S")
            aRandomNumber = random.randint(0, sys.maxsize)
            aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)

            # 1st page for user_usage
            if not page_token:
                taskqueue.add(queue_name=queue_name[1], name='opuu_1_' + dateref + '_' + aNumber,
                              url='/one_page_user_usage?token=&date=' + dateref, method='GET')

            for pages_token in returnUserUsageToken(dateref, cfg['credentials']['general'],
                                                    cfg['super_admin']['delegated'], page_token):
                if not pages_token:
                    break
                pages += 1

                tNow = datetime.now()
                aNumber = tNow.strftime("%S")
                aRandomNumber = random.randint(0, sys.maxsize)
                aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)
                qA = random.randint(0, numQueues - 1)

                taskqueue.add(queue_name=queue_name[qA], name='opuu' + dateref + '_' + str(pages) + '_' + aNumber,
                              url='/one_page_user_usage?token=' + pages_token + '&date=' + dateref, method='GET')

                if pages >= maxPages:
                    taskqueue.add(queue_name=queue_name[qA], name='uu' + dateref + '_' + aNumber,
                                  url='/user_usage?token=' + pages_token + '&date=' + dateref, method='GET')
                    break

            logging.info('User Usage pages for {} - {} / finally {} pages '.format(dateref, cfg['domains'], pages))
            self.response.write("User Usage for {} - {} / {} pages".format(dateref, cfg['domains'], pages))
        except Exception as err:
            logging.error(err)
            self.response.write('User Usage for ' + dateref + ' - ' + cfg['domains'] + ': ERROR')
            raise err

        bvi_log(date=dateref, resource='user_usage', message_id='end', message='End of /user_usage call')


application = webapp2.WSGIApplication([('/user_usage', PrintUserUsage)],
                                      debug=True)