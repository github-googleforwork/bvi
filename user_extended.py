#!/usr/bin/python
#
# Copyright 2016 Google Inc.
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

# This file implements PrintUsers, getting the GSuite Directory API User list report for a given date

import logging
import webapp2
from main import returnUsersListGeneratorExtended, writeDatainBigQuery
from datetime import date

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class PrintUsersExtended(webapp2.RequestHandler):
    def get(self):
        # User List today
        today = date.today()
        dDate = today.strftime("%Y-%m-%d")
        decoratorDate = today.strftime("%Y%m%d")
        users = 0
        domains = list(set(cfg['domains'].split(";")))
        for domain in domains:
            domain = domain.strip()
            for user_list in returnUsersListGeneratorExtended(domain, cfg['credentials']['general'],
                                                              cfg['super_admin']['delegated']):
                users += len(user_list)
                logging.info("User List === {}".format(user_list))
                logging.info('User list for {} - {} / {} so far until now'.format(dDate, domain, users))
                bq_answer = writeDatainBigQuery(user_list, 'users_list_date_extended${decoratorDate}'.format(
                    decoratorDate=decoratorDate))
            logging.info('User list for {} - {} / finally ... {} '.format(dDate, domain, users))
            self.response.write("User Extended list for {dDate} - {domain} / ... {length}".format(
                dDate=dDate,
                domain=domain,
                length=users
            )
            )


application = webapp2.WSGIApplication([('/user_extended', PrintUsersExtended)],
                                      debug=True)