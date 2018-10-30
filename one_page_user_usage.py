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
# Enhanced by: Julio Quinteros <julioandres@google.com>
# Enhanced by: Thomas Cliett <thomascliett@google.com>

# This file implements PrintOneUserUsage, getting the GSuite Reports API User Usage report for a given user and date
# Parameters:
# token
# date: YYYY-MM-DD

import webapp2
from main import returnUserUsagePageToken, writeDatainBigQuery
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintOnePageUserUsage(webapp2.RequestHandler):
    def get(self):
        # User Usage for a date One page at a time
        token = self.request.get('token')
        dDate = self.request.get('date')
        decoratorDate = "".join(dDate.split("-"))
        for report_items in returnUserUsagePageToken(token, dDate, cfg['credentials']['general'],
                                                     cfg['super_admin']['delegated']):
            try:
                writeDatainBigQuery(report_items,
                                    'user_usage${decoratorDate}'.format(decoratorDate=decoratorDate))
            except Exception as err:
                bvi_log(date=dDate, resource='user_usage', message_id='bigquery_error', message=err,
                        regenerate=True)
                raise err


application = webapp2.WSGIApplication([('/one_page_user_usage', PrintOnePageUserUsage)], debug=True)
