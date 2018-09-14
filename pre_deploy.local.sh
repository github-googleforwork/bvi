#!/bin/bash
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

# Author: Julio Quinteros
# Enhanced by: Ismael Yuste <ismaelyuste@google.com>
# This file should be run prior to deploy.sh on a local environment

BUSINESS_PLAN='Business'
ENTERPRISE_PLAN='Enterprise'

#read configuration!
if [ -f config.yaml ]; then
	. parse_yaml.sh
	eval "$(parse_yaml config.yaml 'bvicfg_')"
fi
echo "Hello, "$USER".  We will setup some information before deploying."

# DOMAIN(S)
if [ ! -z "${bvicfg_domains}" ]; then
	echo "Current domain(s): ${bvicfg_domains}"
	echo -n "Enter your domain or domains separated by semicolon (;) and press [ENTER] (if you provide nothing, no update is made): "
	read domains
	domain=${domain:=${bvicfg_domains}}
else
	echo -n "Enter your domain or domains separated by semicolon (;) and press [ENTER]: "
	read domains
fi
echo

# PLAN
plan_option=''
echo "Current G Suite plan: ${bvicfg_plan}"
while [ "${plan_option}" != 'b' ] && [ "${plan_option}" != 'B' ] && [ "${plan_option}" != 'e' ] && [ "${plan_option}" != 'E' ] ; do
    echo -n "What's your G Suite plan? Type B for Basic/Business or E for Enterprise [B/E]: "
    read plan_option
done
if [ "${plan_option}" = 'E' ] || [ "${plan_option}" = 'e' ]; then
    plan=$ENTERPRISE_PLAN
else
    plan=$BUSINESS_PLAN
fi
echo

# PROJECT ID
if [ ! -z "${bvicfg_ids_project_id}" ] || [ ! -z "${DEVSHELL_PROJECT_ID}" ]; then
    current_project_id=${bvicfg_ids_project_id}
    current_project_id=${current_project_id:=${DEVSHELL_PROJECT_ID}}
	echo "Current project id: ${current_project_id}"
	echo -n "Enter your project id and press [ENTER] (if you provide nothing, no update is made): "
	read project_id
	project_id=${project_id:=${current_project_id}}
else
	echo -n "Enter your project id and press [ENTER]: "
	read project_id
fi
echo

# MAX PAGES
if [ ! -z "${bvicfg_task_management_max_pages}" ]; then
	echo "Current max_pages ${bvicfg_task_management_max_pages}"
	echo -n "Enter the preferred max_pages value and press [ENTER] (if you provide nothing, no update is made): "
	read max_pages
	max_pages=${max_pages:=${bvicfg_task_management_max_pages}}
else
	echo -n "Enter the preferred max_pages value and press [ENTER] (default 200): "
	read max_pages
	max_pages=${max_pages:=200}
fi
echo

# PAGE SIZE
if [ ! -z "${bvicfg_task_management_page_size}" ]; then
	echo "Current page_size ${bvicfg_task_management_page_size}"
	echo -n "Enter the preferred page_size value and press [ENTER] (if you provide nothing, no update is made): "
	read page_size
	page_size=${page_size:=${bvicfg_task_management_page_size}}
else
	echo -n "Enter the preferred page_size value and press [ENTER] (default 100): "
	read page_size
	page_size=${page_size:=100}
fi
echo

# PAGE SIZE USER USAGE
if [ "${plan}" == $BUSINESS_PLAN ]; then
    if [ ! -z "${bvicfg_task_management_page_size_user_usage}" ]; then
        echo "Current page_size_user_usage ${bvicfg_task_management_page_size_user_usage}"
        echo -n "Enter the preferred page_size_user_usage value and press [ENTER] (if you provide nothing, no update is made): "
        read page_size_user_usage
        page_size_user_usage=${page_size_user_usage:=${bvicfg_task_management_page_size_user_usage}}
    else
        echo -n "Enter the preferred page_size_user_usage value and press [ENTER] (default 50): "
        read page_size_user_usage
        page_size_user_usage=${page_size_user_usage:=50}
    fi
fi
echo

# SUPER ADMIN DELEGATED
if [ ! -z "${bvicfg_super_admin_delegated}" ]; then
	echo "Current delegated super admin: ${bvicfg_super_admin_delegated}"
	echo -n "Enter the email for the delegated super admin, and press [ENTER] (if you provide nothing, no update is made): "
	read super_admin_email
	super_admin_email=${super_admin_email:=${bvicfg_super_admin_delegated}}
else
	echo -n "Enter the email for the delegated super admin, and press [ENTER]: "
	read super_admin_email
fi
echo

# GOOGLE SHEET LINK
if [ ! -z "${bvicfg_google_sheets_link}" ]; then
	echo "Current Business survey sheet link: ${bvicfg_google_sheets_link}"
	echo -n "Enter the link of survey spreadsheet and press [ENTER] (if you provide nothing, no update is made): "
	read google_sheets_link
	google_sheets_link=${google_sheets_link:=${bvicfg_google_sheets_link}}
else
	echo -n "Enter the link of survey spreadsheet and press [ENTER]: "
	read google_sheets_link
fi
echo

# CUSTOM FIELDS SHEET LINK
if [ ! -z "${bvicfg_custom_fields_sheets_link}" ]; then
	echo "Current custom fields sheet link: ${bvicfg_custom_fields_sheets_link}"
	echo -n "Enter the link of custom fields spreadsheet and press [ENTER] (if you provide nothing, no update is made): "
	read custom_fields_sheets_link
	custom_fields_sheets_link=${custom_fields_sheets_link:=${bvicfg_custom_fields_sheets_link}}
else
	echo -n "Enter the link of custom fields spreadsheet and press [ENTER]: "
	read custom_fields_sheets_link
fi
echo

# NOTIFICATION EMAIL
if [ ! -z "${bvicfg_notification_email}" ]; then
	echo "Current notification email(s): ${bvicfg_notification_email}"
	echo -n "Enter the emails separated by semicolon "\;" to receive the notification, and press [ENTER] (if you provide nothing, no update is made): "
	read notification_email
	notification_email=${notification_email:=${bvicfg_notification_email}}
else
	echo -n "Enter the emails separated by semicolon "\;" to receive the notification, and press [ENTER]: "
	read notification_email
fi
echo

# YAML FILES CREATION
if [ "${plan}" == 'Enterprise' ]; then
    sed "s|MAX_NUMBER_PAGES_Recommended_200|${max_pages}|g; s|MAX_NUMBER_ROWS_PER_PAGE_Recommended_500|${page_size}|g;s|YOUR_EMAIL|${super_admin_email}|g; s|YOUR_DOMAINS_SEPARATED_BY_SEMICOLON|${domains}|g; s|YOUR_PROJECT_ID|${project_id}|g; s|GOOGLE_SHEETS_LINK|${google_sheets_link}|g; s|CUSTOM_FIELDS_SHEETS_LINK|${custom_fields_sheets_link}|g; s|NOTIFICATION_EMAIL|${notification_email}|g" config.yaml.esku.template > config.yaml
    cp app.yaml.esku.template app.yaml
    cp queue.yaml.esku.template queue.yaml
    cp manager.yaml.esku.template manager.yaml
    cp manager_historical.yaml.esku.template manager_historical.yaml
else
    sed "s|MAX_NUMBER_PAGES_Recommended_200|${max_pages}|g; s|MAX_NUMBER_ROWS_PER_PAGE_Recommended_500|${page_size}|g; s|MAX_NUMBER_ROWS_PER_PAGE_USER_USAGE_Recommended_50|${page_size_user_usage}|g; s|YOUR_EMAIL|${super_admin_email}|g; s|YOUR_DOMAINS_SEPARATED_BY_SEMICOLON|${domains}|g; s|YOUR_PROJECT_ID|${project_id}|g; s|GOOGLE_SHEETS_LINK|${google_sheets_link}|g; s|CUSTOM_FIELDS_SHEETS_LINK|${custom_fields_sheets_link}|g; s|NOTIFICATION_EMAIL|${notification_email}|g" config.yaml.template > config.yaml
    cp app.yaml.template app.yaml
    cp queue.yaml.template queue.yaml
    cp manager.yaml.template manager.yaml
    cp manager_historical.yaml.template manager_historical.yaml
fi

echo "config.yaml has been generated. Please check it before deploying!"
echo "CHECK 1: Put your credential files under credentials folder and set them properly in config.yaml"
echo "CHECK 2: If you set any of the spreadsheets (business survey or custom fields), "
echo "         share these spreadsheets with the same service account email address used to access BigQuery data."
echo "CHECK 3: When using BigQuery export from GSuite to a dataset different from the default one (Reports),"
echo "         set the correct name in 'export_dataset' in config.yaml"
