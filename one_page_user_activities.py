# !/usr/bin/python
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

# This file implements PrintOneUserActivities, getting the GSuite Reports API Activities report for a given user, application and date
# Parameters:
# token
# app: calendar|drive|groups|login|mobile|token
# date: YYYY-MM-DD

import webapp2
from main import writeDatainBigQuery
from main import returnActivitiesPageToken
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintOnePageUserActivities(webapp2.RequestHandler):
    def get(self):
        # User Activities for a date and app One page at a time
        token = self.request.get('token')
        app = self.request.get('app')
        dDate = self.request.get('date')
        decoratorDate = ("").join(dDate.split("-"))
        for report_items in returnActivitiesPageToken(token, app, dDate, cfg['credentials']['general'],
                                                      cfg['super_admin']['delegated']):
            try:
                bq_answer = writeDatainBigQuery(report_items,
                                                'audit_log${decoratorDate}'.format(decoratorDate=decoratorDate))
            except Exception as err:
                bvi_log(date=dDate, resource='activities', message_id='bigquery_error', message=err,
                        regenerate=True)
                raise err


application = webapp2.WSGIApplication([('/one_page_user_activities', PrintOnePageUserActivities)],
                                      debug=True)