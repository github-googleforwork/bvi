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

import logging
import webapp2
from datetime import date, timedelta

from main import createBigQueryService
from bigquery_api import fetch_big_query_table_info

import yaml
with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

if cfg['plan'] == 'Enterprise':
    from bigquery_cfg_esku import setup as bigquery_setup
else:
    from bigquery_cfg import setup as bigquery_setup


class CreateVolumeReport(webapp2.RequestHandler):
    def get(self):
        logging.info('Create Volume Report')


        sDate = self.request.get('sDate')
        eDate = self.request.get('eDate')

        start_date = date(int(sDate.split('-')[0]), int(sDate.split('-')[1]), int(sDate.split('-')[2]))
        end_date = date(int(eDate.split('-')[0]), int(eDate.split('-')[1]), int(eDate.split('-')[2]))
        date_delta = timedelta(days=1)

        scopes = cfg['scopes']['big_query']
        project_id = cfg['ids']['project_id']
        bigquery = createBigQueryService(scopes, 'bigquery', 'v2')

        for table in bigquery_setup['tables']:

            logging.info('Start generating volume info for table [{}]'.format(table['name']))

            day_date = start_date
            while day_date <= end_date:
                logging.info("Generating volume for date {}".format(day_date.strftime("%Y-%m-%d")))

                yyyy, mm, dd = day_date.strftime("%Y-%m-%d").split("-")
                decorator_date = "{yyyy}{mm}{dd}".format(yyyy=yyyy, mm=mm, dd=dd)
                table_name_decorator = table['name'] + '$' + decorator_date
                table_level = table['level'] if ('level' in table) else 'raw_data'
                table_type = table['type']

                info = fetch_big_query_table_info(bigquery, project_id, table['dataset'], table_name_decorator)

                num_rows = info['numRows'] if ('numRows' in info) else '0'
                num_bytes = info['numBytes'] if ('numBytes' in info) else '0'

                log_info = "TABLE_INFO: TABLE:{}, TABLE_DECORATOR:{}, LEVEL:{}, " \
                           "TYPE:{}, NUM_ROWS:{}, NUM_BYTES:{}".format(
                    table['name'], table_name_decorator, table_level, table_type, num_rows, num_bytes)

                logging.info(log_info)

                day_date += date_delta


application = webapp2.WSGIApplication([('/create_volume_report', CreateVolumeReport)],
                                      debug=True)