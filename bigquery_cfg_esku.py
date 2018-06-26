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
# This file has all the needed table and view definitions used on bigquery_api file to create the BQ schema.

setup = {}
setup['folder'] = 'schemas/bigquery_esku'

setup['datasets'] = [
    {
        'name': 'raw_data',
        'description': 'Raw data',
    },
    {
        'name': 'users',
        'description': 'Users related data',
    },
    {
        'name': 'adoption',
        'description': 'Adoption related data',
    },
    {
        'name': 'profiles',
        'description': 'Users profiling data',
    },
    {
        'name': 'survey',
        'description': 'Business Impact Survey data',
    },
    {
        'name': 'custom',
        'description': 'Custom fields data',
    },
    {
        'name': 'billing',
        'description': 'Billing data',
    }
]

setup['tables'] = [
    {
        'name': 'users_list_date',
        'dataset': 'raw_data',
        'description': 'Historical Registry of the Organization Users',
        'schema': {
            'fields': [
                {
                    "mode": "NULLABLE",
                    "name": "date",
                    "type": "STRING"
                },
                {
                    "mode": "NULLABLE",
                    "name": "primaryEmail",
                    "type": "STRING"
                },
                {
                    "mode": "NULLABLE",
                    "name": "creationTime",
                    "type": "TIMESTAMP"
                },
                {
                    "mode": "REPEATED",
                    "name": "emails",
                    "type": "RECORD",
                    "fields": [
                        {
                            "mode": "NULLABLE",
                            "name": "primary",
                            "type": "BOOLEAN"
                        },
                        {
                            "mode": "NULLABLE",
                            "name": "address",
                            "type": "STRING"
                        },
                        {
                            "mode": "NULLABLE",
                            "name": "customType",
                            "type": "STRING"
                        },
                        {
                            "mode": "NULLABLE",
                            "name": "type",
                            "type": "STRING"
                        },
                    ]
                },
                {
                    "mode": "NULLABLE",
                    "name": "lastLoginTime",
                    "type": "TIMESTAMP"
                },
                {
                    "mode": "NULLABLE",
                    "name": "customerId",
                    "type": "STRING"
                },
                {
                    "mode": "NULLABLE",
                    "name": "orgUnitPath",
                    "type": "STRING"
                }
            ]
        },
        'timePartitioning': {
            'type': 'DAY',
        },
        'type': 'table',
    },
    {
        'name': 'visibility_level',
        'dataset': 'adoption',
        'description': 'File visibility levels from the most private to the most public',
        'type': 'view',
    },
    {
        'name': 'users_list_domain',
        'dataset': 'users',
        'description': 'Domain for the emails of this organization',
        'level': 1,
        'type': 'table_from_view',
    },
    {
        'name': 'audit_log_profilable_events',
        'dataset': 'raw_data',
        'description': 'Events that are relevant for further analysis',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 1,
        'type': 'table_from_view',
    },
    {
        'name': 'latest_date_customer_usage',
        'dataset': 'raw_data',
        'description': 'Available dates for customer_usage (from more recent to oldest)',
        'type': 'view',
    },
    {
        'name': 'latest_date_user_usage',
        'dataset': 'raw_data',
        'description': 'Available dates for user_usage (from more recent to oldest)',
        'type': 'view',
    },
    {
        'name': 'latest_date_users_list_date',
        'dataset': 'raw_data',
        'description': 'Available dates for users_list_date (from more recent to oldest)',
        'type': 'view',
    },
    {
        'name': 'users_ou_list',
        'dataset': 'users',
        'description': 'List of users that exist in raw_data.users_list_date within 30 days ago',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 1,
        'type': 'table_from_view',
    },
    {
        'name': 'drive_active_users_30day',
        'dataset': 'users',
        'description': 'count of distinct active drive users over the past 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 1,
        'type': 'table_from_view',
    },
    {
        'name': 'meetings_adoption_daily',
        'dataset': 'adoption',
        'description': 'Daily meetings metrics extracted',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 1,
        'type': 'table_from_view',
    },
    {
        'name': 'meetings_latest_30day_summary',
        'dataset': 'adoption',
        'description': 'Summary with many meetings metrics calculated from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'meetings_per_calls_group',
        'dataset': 'adoption',
        'description': 'Meetings summary grouped by calls group from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'calls_by_users_type_pie_chart',
        'dataset': 'adoption',
        'description': 'Calls info grouped by type of users calculated from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'meetings_by_users_type_pie_chart',
        'dataset': 'adoption',
        'description': 'Meetings info grouped by type of users calculated from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'calls_time_spent_latest_30day_by_device',
        'dataset': 'adoption',
        'description': 'Calls time spent grouped by device calculated from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'calls_time_spent_latest_30day_by_user_type',
        'dataset': 'adoption',
        'description': 'Calls time spent grouped by user type calculated from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'num_calls_latest_30day_by_device',
        'dataset': 'adoption',
        'description': 'Number of calls grouped by device type calculated from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'meetings_30day_summary',
        'dataset': 'adoption',
        'description': 'Number of calls grouped by device type calculated over the past 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'calls_time_spent_30day_by_user_type',
        'dataset': 'adoption',
        'description': 'Calls time spent grouped by user type calculated over the past 30 days',
        'type': 'view',
    },
    {
        'name': 'calls_time_spent_30day_by_device',
        'dataset': 'adoption',
        'description': 'Calls time spent grouped by device calculated over the past 30 days',
        'type': 'view',
    },
    {
        'name': 'audit_log_active_users_per_day',
        'dataset': 'users',
        'description': 'Active users list that exist in raw_data.audit_log within 30 days ago',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'collab_profiles_30day',
        'dataset': 'profiles',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'profiles_any_per_day_no_ou',
        'dataset': 'profiles',
        'description': 'Users classified on profiles, daily',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'gmail_active_users_30day',
        'dataset': 'users',
        'description': 'count of distinct active gmail users over the past 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'gmail_users_1day',
        'dataset': 'users',
        'description': 'Gmail users per day',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'gmail_users_30day',
        'dataset': 'users',
        'description': '30 day active users gmail users per day by list of email',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'total_users_30day',
        'dataset': 'users',
        'description': 'count of distinct total users (active + inactive) over the past 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_all_files_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_drawings_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_editors_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_forms_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_non_native_files_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_presentations_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_readers_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_spreadsheets_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_text_documents_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'drive_users_1day',
        'dataset': 'users',
        'description': 'Drive users per day',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'drive_users_30day',
        'dataset': 'users',
        'description': '30 day drive users per day',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'product_adoption_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'user_usage_drive_stats_whole_history',
        'dataset': 'adoption',
        'description': 'General metrics for adoption (like num_docs_viewed, num_docs_edited, drive_adoption), per user, per day, with users ou, historical registry.',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'product_adoption_30day',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'user_usage_gplus_daily',
        'dataset': 'adoption',
        'description': 'gplus metrics daily usage metrics per user',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 2,
        'type': 'table_from_view',
    },
    {
        'name': 'latest_date_audit_log',
        'dataset': 'raw_data',
        'description': 'Available dates for audit log (from more recent to oldest)',
        'type': 'view',
    },
    {
        'name': 'adoption_latest_extended',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'gplus_30day_summary_latest',
        'dataset': 'adoption',
        'description': 'Latest summary with gplus metrics calculated from the past 30 days',
        'type': 'view',
    },
    {
        'name': 'active_users_with_ou_per_day',
        'dataset': 'users',
        'description': 'Active users list that exist in raw_data.audit_log_active_users_per_day, adding their ou',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 3,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'collab_profiles_base',
        'dataset': 'profiles',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 3,
        'type': 'table_from_view',
    },
    {
        'name': 'audit_log_active_users_per_day_drive_gmail',
        'dataset': 'users',
        'description': 'Distinct drive and gmail users per day',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 3,
        'type': 'table_from_view',
    },
    {
        'name': 'total_active_users_30day',
        'dataset': 'users',
        'description': 'count of distinct active users from drive and gmail over the past 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 3,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'google_drive_adoption_stats_per_day_per_ou',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 3,
        'type': 'table_from_view',
    },
    {
        'name': 'total_active_users_1day',
        'dataset': 'users',
        'description': 'count of distinct active users from drive and gmail for each day',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 3,
        'type': 'table_from_view',
    },
    {
        'name': 'latest_date',
        'dataset': 'raw_data',
        'description': 'Available dates for the base tables (from more recent to oldest)',
        'type': 'view',
    },
    {
        'name': 'collab_profiles_pie_chart_extended',
        'dataset': 'profiles',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'product_adoption_latest',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'content_latest_1d',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'content_latest_30d',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'audit_log_drive_adoption_per_day',
        'dataset': 'adoption',
        'description': 'Users that have been active in drive events',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
    {
        'name': 'active_users',
        'dataset': 'users',
        'description': 'Active users list that exist in users.active_users_with_ou_per_day, by taking its latest date available (as a last seen date)',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
{
        'name': 'profiles_any_per_day_per_ou',
        'dataset': 'profiles',
        'description': 'Users classified on profiles, daily, with ou',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
    {
        'name': 'adoption_30day',
        'dataset': 'adoption',
        'description': 'count of distinct active gmail, drive, and unique active users over the past 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'content_daily',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
    {
        'name': 'active_users_30da_per_ou',
        'dataset': 'users',
        'description': 'Active users list that exist in raw_data.audit_log_active_users_per_day, adding their ou, for the time window of 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
    {
        'name': 'active_users_with_ou_per_day_drive_gmail',
        'dataset': 'users',
        'description': 'Distinct drive and gmail users with ou',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
    {
        'name': 'gplus_adoption_daily',
        'dataset': 'adoption',
        'description': 'Daily gplus metrics extracted',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 4,
        'type': 'table_from_view',
    },
    {
        'name': 'adoption_30day_latest',
        'dataset': 'adoption',
        'description': 'Latest 30 day users by product, based on aggregation at the user level',
        'type': 'view',
    },
    {
        'name': 'product_adoption_latest_30d',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'collab_adoption_30day',
        'dataset': 'adoption',
        'description': 'Number of unique users by profile type over the last 30days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'editor_adoption_per_day_per_ou',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'drive_adoption_per_day_per_ou',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        'name': 'active_users_30da',
        'dataset': 'users',
        'description': 'Active users list that exist in raw_data.audit_log_active_users_per_day, adding their ou',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'collab_profiles_daily',
        'dataset': 'profiles',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        'name': 'profiles_any_per_ou_last_N_days',
        'dataset': 'profiles',
        'description': 'Users classified on profiles, with ou, daily, within last 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        'name': 'active_users_drive_gmail',
        'dataset': 'users',
        'description': 'Distinct drive and gmail users with no ou',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        'name': 'gplus_30day_summary',
        'dataset': 'adoption',
        'description': 'Summary with gplus metrics calculated from the past 30 days',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        'name': 'engagement_gplus_daily',
        'dataset': 'adoption',
        'description': 'Engagement of Google+ users daily',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 5,
        'type': 'table_from_view',
    },
    {
        'name': 'trend_collab_adoption_30day',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'editor_adoption',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'drive_adoption',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'profiles_any_last_N_days',
        'dataset': 'profiles',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'collab_adoption_30day_latest',
        'dataset': 'adoption',
        'description': '30day profiles by raw numbers and percentage for today - 4 days',
        'type': 'view',
    },
    {
        'name': 'collab_adoption_30day_latest_pie_chart',
        'dataset': 'adoption',
        'description': '30day profiles by raw numbers and percentage for today - 4 days to be used on pie charts',
        'type': 'view',
    },
    {
        'name': 'gplus_adoption_daily_latest',
        'dataset': 'adoption',
        'description': 'gplus adoption from last calculated day',
        'type': 'view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'adoption',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 6,
        'type': 'table_from_view',
    },
    {
        # Notice this view definition
        # requires YOUR_TIMESTAMP_PARAMETER to be replaced
        # before executing
        'name': 'collab_profiles',
        'dataset': 'profiles',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 6,
        'type': 'table_from_view',
    },
    {
        'name': 'adoption_latest',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'collaboration_adoption_latest_30d',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'collab_profiles_latest',
        'dataset': 'profiles',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'collab_profiles_pie_chart',
        'dataset': 'profiles',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'trend_adoption_30day',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'trend_content_latest_30day',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'adoption_per_product',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'adoption_all_products_30day',
        'dataset': 'adoption',
        'description': '',
        'type': 'view',
    },
    {
        'name': 'adoption_all_products_30day_for_filter',
        'dataset': 'adoption',
        'description': '',
        'timePartitioning': {
            'type': 'DAY',
        },
        'level': 7,
        'type': 'table_from_view',
    }
]