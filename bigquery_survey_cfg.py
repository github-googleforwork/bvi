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

setup = {}
setup['folder'] = 'schemas/bigquery_survey'

setup['tables'] = [
    {
        'name': 'raw_form_responses',
        'dataset': 'survey',
        'description': 'Raw Form Responses',
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
                        "name": "timestamp",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "business_function",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "location",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_drive",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_docs",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_slides",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_sheets",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_hangouts_chat",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_hangouts_video",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_sites",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_forms",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_often_do_you_use_the_following_tools_google_plus",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_drive",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_docs",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_slides",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_sheets",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_hangouts_chat",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_hangouts_video",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_sites",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_forms",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_well_would_you_rate_your_ability_to_use_the_following_products_google_plus",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_helpful_did_or_do_you_find_the_following_training_resources_In_class_training",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_helpful_did_or_do_you_find_the_following_training_resources_online_training",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_helpful_did_or_do_you_find_the_following_training_resources_going_google_site",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_helpful_did_or_do_you_find_the_following_training_resources_peer_support_google_guides",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_helpful_did_or_do_you_find_the_following_training_resources_other",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "if_you_selected_other_please_specify_the_method_of_training",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_has_your_productivity_increased_or_decreased_when_using_g_suite",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_has_your_collaboration_with_colleagues_on_work_increased_or_decreased_when_using_g_suite",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_has_your_ability_to_connect_with_colleagues_outside_of_your_primary_location_changed_since_using_google_apps_DEPRECATED",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_have_you_increased_or_decreased_your_usage_of_mobile_devices_e_g_mobile_phones_tablets_DEPRECATED",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_have_you_been_able_to_work_more_or_less_outside_of_your_primary_work_location_since_using_google_apps_DEPRECATED",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_do_you_agree_or_disagree_as_a_result_of_using_g_suite_i_am_more_flexible_in_where_i_can_work_and_or_what_device_i_use",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_do_you_agree_or_disagree_to_the_as_a_result_of_using_g_suite_my_organization_is_more_innovative",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "degree_do_you_agree_or_disagree_as_a_result_of_using_google_apps_my_organization_is_more_innovative_DEPRECATED",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "if_you_scored_any_of_the_above_statements_with_negative_numbers_or_disagree_please_comment_below_to_provide_more_context",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "how_many_hours_do_you_save_or_expect_to_save_per_week_using_g_suite",
                        "type": "STRING"
                    },
                    {
                        "mode": "NULLABLE",
                        "name": "please_provide_any_examples_of_how_google_has_positively_impacted_your_work",
                        "type": "STRING"
                    }
                ]
            },
        },
        'type': 'table',
    },
    {
        'name': 'form_responses',
        'dataset': 'survey',
        'description': 'Form responses',
        'type': 'view',
    },
    {
        'name': 'language',
        'dataset': 'survey',
        'description': 'Language translation',
        'type': 'view',
    },
    {
        'name': 'training',
        'dataset': 'survey',
        'description': 'Training data',
        'type': 'view',
    },
    {
        'name': 'impact_by_department',
        'dataset': 'survey',
        'description': 'Impact by department',
        'type': 'view',
    },
    {
        'name': 'impact_by_location',
        'dataset': 'survey',
        'description': 'Impact by location',
        'type': 'view',
    },
    {
        'name': 'impact_by_products',
        'dataset': 'survey',
        'description': 'Impact by products',
        'type': 'view',
    },
    {
        'name': 'impact_by_products_rates',
        'dataset': 'survey',
        'description': 'Impact by products rates',
        'type': 'view',
    },
    {
        'name': 'impact_by_products_gain_period',
        'dataset': 'survey',
        'description': 'Impact by products gain period',
        'type': 'view',
    },
    {
        'name': 'calc_form_responses',
        'dataset': 'survey',
        'description': 'Form responses view with calculated fields',
        'type': 'view',
    },
    {
        'name': 'calc_form_responses_grouped',
        'dataset': 'survey',
        'description': 'Form responses view grouped by Business Function with calculated fields',
        'type': 'view',
    },
    {
        'name': 'calc_impact_by_department',
        'dataset': 'survey',
        'description': 'Impact by Department view with calculated fields',
        'type': 'view',
    },
    {
        'name': 'calc_impact_by_department_grouped',
        'dataset': 'survey',
        'description': 'Impact by Department view grouped by Department with calculated fields',
        'type': 'view',
    },
    {
        'name': 'calc_impact_by_location',
        'dataset': 'survey',
        'description': 'Impact by Location view with calculated fields',
        'type': 'view',
    },
    {
        'name': 'calc_impact_by_products_rates',
        'dataset': 'survey',
        'description': 'Impact by Location view with calculated fields',
        'type': 'view',
    },
    {
        'name': 'usage_by_docs',
        'dataset': 'survey',
        'description': 'How often Docs is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_drive',
        'dataset': 'survey',
        'description': 'How often Drive is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_forms',
        'dataset': 'survey',
        'description': 'How often Forms is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_google_plus',
        'dataset': 'survey',
        'description': 'How often Google Plus is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_hangouts_chat',
        'dataset': 'survey',
        'description': 'How often Hangouts Chat is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_hangouts_video',
        'dataset': 'survey',
        'description': 'How often Hangouts Video is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_sheets',
        'dataset': 'survey',
        'description': 'How often Sheets is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_sites',
        'dataset': 'survey',
        'description': 'How often Sites is used',
        'type': 'view',
    },
    {
        'name': 'usage_by_slides',
        'dataset': 'survey',
        'description': 'How often Slides is used',
        'type': 'view',
    },
]