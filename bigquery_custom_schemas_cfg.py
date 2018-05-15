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
# This file has all the needed table and view definitions used on bigquery_api file to create the custom fields.

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

setup = {}

setup['folder'] = 'schemas/bigquery_esku/bigquery_custom_schemas' if cfg['plan'] == 'Enterprise' \
    else 'schemas/bigquery/bigquery_custom_schemas'

setup['datasets'] = [
    {
        'name': 'custom',
        'description': 'Contains the custom table to handle custom fields',
    }
]

setup['tables'] = [
    {
        'name': 'custom_fields',
        'dataset': 'custom',
        'description': 'table to hold custom fields',
        'externalDataConfiguration': {
            'googleSheetsOptions': {
                "skipLeadingRows": 1
            },
            'sourceFormat': 'GOOGLE_SHEETS',
            'sourceUris': [
                'YOUR_GOOGLE_SHEETS_LINK'
            ],
            'schema': {
                'fields': [
                    {
                        "mode": "NULLABLE",
                        "name": "email",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "custom_1",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "custom_2",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "custom_3",
                        "type": "STRING"
                    }
                ]
            },
        },
        'type': 'table',
    },
    {
        'name': 'raw_custom_fields',
        'dataset': 'custom',
        'description': '',
        'level': '1',
        'type': 'table_from_view',
    },
    {
        'name': 'custom_drive_adoption_per_day_per_ou',
        'dataset': 'custom',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': '1',
        'type': 'table_from_view',
    },
    {
        'name': 'custom_drive_adoption',
        'dataset': 'custom',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'custom_profiles_any_per_ou_last_N_days',
        'dataset': 'custom',
        'description': 'Users classified on profiles, with ou, customs, daily, within last 30 days',
        'type': 'view',
    },
    {
        'name': 'custom_active_users_30da_per_ou',
        'dataset': 'custom',
        'description': 'Active users list that exist in raw_data.audit_log_active_users_per_day, adding their ou and customs, for the time window of 30 days',
        'type': 'view',
    },
    {
        'name': 'custom_collab_profiles',
        'dataset': 'custom',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': '1',
        'type': 'table_from_view',
    },
    {
        'name': 'custom_collab_profiles_latest',
        'dataset': 'custom',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'custom_product_adoption_daily',
        'dataset': 'custom',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': '1',
        'type': 'table_from_view',
    },
    {
        'name': 'custom_product_adoption_30day',
        'dataset': 'custom',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': '1',
        'type': 'table_from_view',
    }
]
