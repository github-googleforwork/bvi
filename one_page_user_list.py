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

# This file implements PrintOneUserListPage, getting the GSuite Reports API User Usage report for a given user and date
# Parameters:
# token
# date: YYYY-MM-DD

import webapp2
import logging
from main import returnUserListPageToken, writeDatainBigQuery
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintOneUserListPage(webapp2.RequestHandler):
    def get(self):
        # User List for a date One page at a time
        token = self.request.get('token')
        domain = self.request.get('domain')
        dDate = self.request.get('date')
        decoratorDate = ("").join(dDate.split("-"))
        try:
            for report_items in returnUserListPageToken(token, dDate, domain, cfg['credentials']['general'],
                                                        cfg['super_admin']['delegated']):
                try:
                    bq_answer = writeDatainBigQuery(report_items, 'users_list_date${decoratorDate}'.format(
                        decoratorDate=decoratorDate))
                except Exception as err:
                    bvi_log(date=dDate, resource='users_list', message_id='bigquery_error', message=err,
                            regenerate=True)
                    raise err

        except Exception as err:
            logging.error(err)
            self.response.write('Users List for ' + dDate + ' - ' + domain + ': ERROR')
            raise err

        bvi_log(date=dDate, resource='users_list', message_id='end', message='End of /one_page_user_list call')


application = webapp2.WSGIApplication([('/one_page_user_list', PrintOneUserListPage)],
                                      debug=True)