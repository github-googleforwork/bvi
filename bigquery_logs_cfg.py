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
# This file has all the needed table and view definitions used on bigquery_api file to create the BQ BIS schema.
import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

setup = {}

setup['folder'] = 'schemas/bigquery_esku' if cfg['plan'] == 'Enterprise' \
    else 'schemas/bigquery'

setup['tables'] = [
    {
        'name': 'raw_logs',
        'dataset': 'logs',
        'description': 'The raw log entries',
        'type': 'view',
    },
    {
        'name': 'bvi_logs',
        'dataset': 'logs',
        'description': 'The bvi log entries',
        'type': 'view',
    },
    {
        'name': 'steps_timestamps',
        'dataset': 'logs',
        'description': 'The timestamps of each step',
        'type': 'view',
    },
    {
        'name': 'pre_dashboard',
        'dataset': 'logs',
        'description': 'Data to be used by the dashboard view',
        'type': 'view',
    },
    {
        'name': 'dashboard',
        'dataset': 'logs',
        'description': 'The main dashboard view',
        'type': 'view',
    },
    {
        'name': 'daily_status',
        'dataset': 'logs',
        'description': 'View to provide the daily status',
        'type': 'view',
    },
    {
        'name': 'errors_dashboard',
        'dataset': 'logs',
        'description': 'Errors Dashboard',
        'type': 'view',
    },
    {
        'name': 'last_executed',
        'dataset': 'logs',
        'description': 'Last executed',
        'type': 'view',
    },
    {
        'name': 'status_board',
        'dataset': 'logs',
        'description': 'Status Board',
        'type': 'view',
    }
]