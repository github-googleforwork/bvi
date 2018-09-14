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

# This file implements PrintCustomer, queriying GSuite Reports API for Customer usage, for a date today - 5 days
# parameters:
# date: YYYY-MM-DD

import logging
import webapp2
from main import returnCustomerUsageReport, writeDatainBigQuery, delete_table_big_query, get_dateref_or_from_cron
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintCustomer(webapp2.RequestHandler):
    def get(self):
        logging.info('Customer Usage')

        dateref = self.request.get('date', "from_cron")

        if len(dateref) > 0:
            try:
                dateref = get_dateref_or_from_cron(dateref)
                dDate = dateref
            except ValueError:
                logging.error("Wrong updating date = {dateref}".format(dateref=dateref))
                self.response.write("Wrong updating date = {}".format(dateref))
                return

        try:
            decoratorDate = "".join(dDate.split("-"))
            table_name = 'customer_usage${decoratorDate}'.format(decoratorDate=decoratorDate)

            # delete table if it exists to avoid data duplication
            delete_table_big_query(table_name)

            for report_items in returnCustomerUsageReport(dDate, cfg['credentials']['general'],
                                                          cfg['super_admin']['delegated']):
                try:
                    writeDatainBigQuery(report_items, table_name)
                    logging.info('Customer Usage for ' + dDate + ' - ' + cfg['domains'] + ' / ')
                    self.response.write('Customer Usage for ' + dDate + ' - ' + cfg['domains'] + ' / ')
                except Exception as err:
                    bvi_log(date=dDate, resource='customer_usage', message_id='bigquery_error', message=err,
                            regenerate=True)
                    raise err
        except Exception as err:
            logging.error(err)
            self.response.write('Customer Usage for ' + dDate + ' - ' + cfg['domains'] + ': ERROR')
            raise err


application = webapp2.WSGIApplication([('/customer', PrintCustomer)],
                                      debug=True)