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
# Checks if the daily execution has failed, if so, an email will be sent to the addresses stored in config.yaml file.

import logging
import webapp2

from datetime import date
from util import send_email

from main import createBigQueryService
from bigquery_api import fetch_big_query_data, convert_big_query_result

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


DAILY_STATUS = {
    '1': 'date',
    '2': 'status',
    '3': 'value'
}


class SendEmailFailure(webapp2.RequestHandler):
    def get(self):

        def prepare_and_send_email():
            to = cfg['notification_email']

            if not to:
                logging.info("No notification email has been setup.")
                return

            sender = 'noreply@{}.appspotmail.com'.format(project_id)
            subject = 'A BVI process has failed.'
            image_link = "https://{}.appspot.com/images/google-cloud.png".format(project_id)

            template_values = {
                'day': day,
                'image_link': image_link
            }

            template_path = 'email_templates/processfailure.html'

            send_email(template_values, template_path, subject, sender, to)

        scopes = cfg['scopes']['big_query']
        project_id = cfg['ids']['project_id']
        bigquery = createBigQueryService(scopes, 'bigquery', 'v2')

        today = date.today()
        day = today.strftime("%Y-%m-%d")

        logging.info('Checking the processes for [{}]'.format(day))

        query = "SELECT date, status, value FROM logs.daily_status ORDER BY date desc LIMIT 1"

        result = fetch_big_query_data(bigquery, project_id, query, 10)
        rows = convert_big_query_result(result, DAILY_STATUS)

        if len(rows) == 0:
            logging.info("There is no result for daily status so there is nothing to do.".format(day))
        elif day == rows[0]['date'] and rows[0]['status'] == 'SUCCESS':
            logging.info("All processes for the day[{}] went well, so no email to be sent.".format(day))
        else:
            logging.info("There is something wrong so an email will be sent to the admin.".format(day))
            prepare_and_send_email()


application = webapp2.WSGIApplication([('/send_failure_email', SendEmailFailure)],
                                      debug=True)
