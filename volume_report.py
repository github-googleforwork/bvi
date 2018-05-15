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
from datetime import datetime
from google.appengine.api import taskqueue

import yaml
with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


class VolumeReport(webapp2.RequestHandler):
    def get(self):
        logging.info('Create Volume Report')

        sDate = self.request.get('sDate')
        eDate = self.request.get('eDate')

        queue_name = cfg['queues']['volume_report']
        url_create_volume = '/create_volume_report?sDate=' + sDate + '&' + 'eDate=' + eDate
        tNow = datetime.now()
        aNumber = tNow.strftime("%S")

        taskqueue.add(queue_name=queue_name,
                      name='VOLUME_REPORT_' + sDate + '_' + aNumber,
                      url=url_create_volume, method='GET')

        self.response.write(' / Starting generating volume report from' + sDate + ' to ' + eDate)


application = webapp2.WSGIApplication([('/volume_report', VolumeReport)], debug=True)
