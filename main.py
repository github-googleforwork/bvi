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

# This is the main class for the project.
# createReportObject
# createBigQueryService
# returnUsersListGenerator
# returnCustomerUsageReport
# returnUserUsageReport
# returnAuditLogReport
# writeDatainBigQuery
# stream_row_to_bigquery
# Implements config.yaml to store all the variables of the project


# Google APIs, BQ and GAE Requirements
import logging
import webapp2
import time
from httplib2 import Http
from google.appengine.api.urlfetch_errors import DeadlineExceededError
from oauth2client.service_account import ServiceAccountCredentials
from googleapiclient.discovery import build
import hashlib
from datetime import date, timedelta
from google.appengine.api import urlfetch
from bvi_logger import bvi_log

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

today = date.today()
dDate = today.strftime("%Y-%m-%d")
maxResultsPage = cfg['task_management']['page_size']
if cfg['plan'] == 'Business':
    maxResultsPage_UserUsage = cfg['task_management']['page_size_user_usage']

#Added to avoid DeadlineExceededError: Deadline exceeded while waiting for HTTP response from URL:
urlfetch.set_default_fetch_deadline(60)

# Create Report Object
# Parameters:
# sScope = Service Scope to Authorise
# report1 = Type of report API object 1
# report2 = Type of report API object 2
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Creates a Reports API object with a JSON file and a defined scope.
# Needs to delegate the credentials, as the service account in the JSON file
# has no credentials to query Google Apps APIs and a SA (SuperAdmin) has.
#
# Returns: Reports API Object to query


def refresh_credentials(credentials, num_retries=5, timeout=5):
    retried = 0
    while retried < num_retries:
        try:
            retried += 1
            http_auth = credentials.authorize(Http(timeout=30))
            break
        except Exception as err:
            if retried == num_retries:
                raise err
            logging.info("Retrying {} of {} token refresh!".format(str(retried), str(num_retries)))
            time.sleep(timeout)
    return http_auth


def execute_request_with_retries(request, num_retries=5, timeout=5):
    retried = 0
    while retried < num_retries:
        try:
            retried += 1
            result = request.execute()
            break
        except Exception as err:
            if retried == num_retries:
                raise err
            logging.info("Retrying {} of {} request!".format(str(retried), str(num_retries)))
            time.sleep(timeout)
    return result


def createReportObject(sScope, report1, report2, SAJson, SADelegated):
    logging.info(sScope)
    logging.info(report1)
    logging.info(report2)
    logging.info(SAJson)

    try:
        logging.info("Impersonating {SA}".format(SA=SADelegated))
        credentials = ServiceAccountCredentials.from_json_keyfile_name(SAJson, sScope)
        logging.info(credentials)
        delegated_credentials = credentials.create_delegated(SADelegated)
        logging.info(delegated_credentials)
        http_auth_delegated = refresh_credentials(delegated_credentials)
        logging.info(http_auth_delegated)
        return build(report1, report2, http=http_auth_delegated)
    except Exception as err:
        logging.error(err)
        raise err


# Create BigQuery Object
# Parameters:
# sScope = Service Scope to Authorise
# report1 = Type of report API object 1
# report2 = Type of report API object 2
#
# Creates a BigQuery object with a JSON file and a defined scope.
#
# Returns: BigQuery Object to query

def createBigQueryService(sScope, report1, report2):
    credentials = ServiceAccountCredentials.from_json_keyfile_name(cfg['credentials']['bigquery'], sScope)
    http_auth = refresh_credentials(credentials)
    bigquery_service = build(report1, report2, credentials=credentials, http=http_auth)
    return bigquery_service


# Review and delete ?
# Returns User List
# Parameters:
# dDomain = Google Apps Domain
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a list of users in a given GAps domain
#
# Returns: JSON list of users, for a give date, with the defined fields

def returnUsersListGenerator(dDomain, SAJson, SADelegated):
    users = []
    page_token = None
    reports = createReportObject(cfg['scopes']['admin_directory'], 'admin', 'directory_v1', SAJson, SADelegated)
    # AVAILABLE FIELDS: https://developers.google.com/admin-sdk/directory/v1/reference/users#resource
    fields = 'nextPageToken,users(creationTime,customerId,emails,lastLoginTime,orgUnitPath,primaryEmail)'
    while True:
        try:
            request = reports.users().list(domain=dDomain, pageToken=page_token, fields=fields)
            results = execute_request_with_retries(request)
            users = results['users']
            logging.info("Page Token {}".format(page_token))
            for user_item in users:
                user_item[u'date'] = dDate
            if 'nextPageToken' in results:
                page_token = results['nextPageToken']
                logging.info("We have {} user rows, and more to come".format(len(users)))
                yield users
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnUsersListGenerator!")
            break
    logging.info("We have {} user rows in the end".format(len(users)))
    yield users


def returnUsersList(dDomain, SAJson, SADelegated):
    all_users = []
    for users in returnUsersListGenerator(dDomain, SAJson, SADelegated):
        all_users += users
    return all_users


def returnTotalUsersList(dDomain, SAJson, SADelegated):
    all_users = []
    for users in returnUsersListGenerator(dDomain, SAJson, SADelegated):
        all_users += users
    return len(all_users)


# Returns Customer Usage Report
# Parameters:
# dDay = A given date
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a Customer Usage Report for a given day -5 (Due to data availability)
#
# Returns: JSON with the Customer Usage Metrics

def returnCustomerUsageReport(dDay, SAJson, SADelegated):
    usage = []
    page_token = None
    try:
        reports = createReportObject(cfg['scopes']['admin_report'], 'admin', 'reports_v1', SAJson, SADelegated)
    except Exception as err:
        bvi_log(date=dDay, resource='customer_usage', message_id='invalid_credential', message=err, regenerate=True)
        raise err

    fields = 'nextPageToken,usageReports(date,entity,parameters)'
    parameters = 'accounts:gsuite_enterprise_used_licenses,accounts:gsuite_enterprise_total_licenses,accounts:gsuite_unlimited_used_licenses,accounts:gsuite_unlimited_total_licenses,accounts:gsuite_basic_used_licenses,accounts:gsuite_basic_total_licenses,accounts:num_disabled_accounts,accounts:num_suspended_users,accounts:num_users,accounts:apps_total_licenses,accounts:apps_used_licenses,accounts:vault_total_licenses,accounts:gsuite_enterprise_used_licenses,accounts:gsuite_basic_used_licenses,accounts:gsuite_unlimited_used_licenses,accounts:gsuite_enterprise_total_licenses,accounts:gsuite_unlimited_total_licenses,accounts:gsuite_basic_total_licenses,accounts:num_1day_logins,accounts:num_7day_logins,accounts:num_30day_logins,' \
                 'calendar:num_1day_active_users,calendar:num_7day_active_users,calendar:num_30day_active_users,' \
                 'cros:num_7day_active_devices,cros:num_30day_active_devices,' \
                 'classroom:num_1day_users,classroom:num_7day_users,classroom:num_30day_users,' \
                 'drive:num_1day_active_users,drive:num_7day_active_users,drive:num_30day_active_users,' \
                 'docs:num_docs,drive:num_1day_active_users,drive:num_7day_active_users,drive:num_30day_active_users,drive:num_30day_google_documents_active_users,drive:num_30day_google_spreadsheets_active_users,drive:num_30day_google_presentations_active_users,drive:num_30day_google_forms_active_users,drive:num_30day_google_drawings_active_users,drive:num_30day_other_types_active_users,drive:num_creators,drive:num_collaborators,drive:num_consumers,drive:num_sharers,' \
                 'gmail:num_1day_active_users,gmail:num_7day_active_users,gmail:num_30day_active_users,' \
                 'gplus:num_1day_active_users,gplus:num_7day_active_users,gplus:num_30day_active_users,' \
                 'device_management:num_30day_google_sync_managed_devices,device_management:num_30day_android_managed_devices,device_management:num_30day_ios_managed_devices,device_management:num_30day_total_managed_devices,device_management:num_30day_google_sync_managed_users,device_management:num_30day_android_managed_users,device_management:num_30day_ios_managed_users,device_management:num_30day_total_managed_users,' \
                 'sites:num_sites,sites:num_sites_created,' \
                 'meet:average_meeting_minutes,meet:average_meeting_minutes_with_11_to_15_calls,meet:average_meeting_minutes_with_16_to_25_calls,meet:average_meeting_minutes_with_26_to_50_calls,meet:average_meeting_minutes_with_2_calls,meet:average_meeting_minutes_with_3_to_5_calls,meet:average_meeting_minutes_with_6_to_10_calls,meet:lonely_meetings,meet:max_concurrent_usage_chromebase,meet:max_concurrent_usage_chromebox,meet:num_1day_active_users,meet:num_30day_active_users,meet:num_7day_active_users,' \
                 'meet:num_calls,meet:num_calls_android,meet:num_calls_by_external_users,meet:num_calls_by_internal_users,meet:num_calls_by_pstn_in_users,meet:num_calls_chromebase,meet:num_calls_chromebox,meet:num_calls_ios,meet:num_calls_jamboard,meet:num_calls_unknown_client,meet:num_calls_web,meet:num_meetings,meet:num_meetings_android,meet:num_meetings_chromebase,meet:num_meetings_chromebox,meet:num_meetings_ios,meet:num_meetings_jamboard,meet:num_meetings_unknown_client,meet:num_meetings_web,' \
                 'meet:num_meetings_with_11_to_15_calls,meet:num_meetings_with_16_to_25_calls,meet:num_meetings_with_26_to_50_calls,meet:num_meetings_with_2_calls,meet:num_meetings_with_3_to_5_calls,meet:num_meetings_with_6_to_10_calls,meet:num_meetings_with_external_users,meet:num_meetings_with_pstn_in_users,meet:total_call_minutes,meet:total_call_minutes_android,meet:total_call_minutes_by_external_users,meet:total_call_minutes_by_internal_users,meet:total_call_minutes_by_pstn_in_users,' \
                 'meet:total_call_minutes_chromebase,meet:total_call_minutes_chromebox,meet:total_call_minutes_ios,meet:total_call_minutes_jamboard,meet:total_call_minutes_unknown_client,meet:total_call_minutes_web,meet:total_meeting_minutes,' \
                 'gplus:num_1day_active_users,gplus:num_7day_active_users,gplus:num_30day_active_users,gplus:num_shares,gplus:num_stream_items_read,gplus:num_plusones,gplus:num_replies,gplus:num_reshares,gplus:num_communities,gplus:num_communities_public,gplus:num_communities_private,gplus:num_communities_organization_wide,gplus:num_communities_organization_private'


    while True:
        try:
            request = reports.customerUsageReports().get(date=dDay, fields=fields, pageToken=page_token,
                                                         parameters=parameters)
            results = execute_request_with_retries(request)
            usage = results.get('usageReports', [])
            if 'nextPageToken' in results:
                page_token = results['nextPageToken']
                logging.info("We have {} customer_usage rows, and more to come".format(len(usage)))
                yield usage
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnCustomerUsageReport!")
            bvi_log(date=dDay, resource='customer_usage', message_id='customer_usage_api', message=err,
                    regenerate=True)
            break
    logging.info("We have {} customer_usage rows in the end".format(len(usage)))
    yield usage


# Review and delete ?
# Returns User Usage Report
# Parameters:
# uUser = User parameter or all for all users
# dDay = A given date
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a User Usage Report for a given day -5 (Due to data availability)
#
# Returns: JSON with the User Usage Metrics

def returnUserUsageReport(uUser, dDay, SAJson, SADelegated):
    user_usage = []
    page_token = None
    reports = createReportObject(cfg['scopes']['admin_report'], 'admin', 'reports_v1', SAJson, SADelegated)
    fields = 'nextPageToken,usageReports(date,entity,parameters)'
    while True:
        try:
            request = reports.userUsageReport().get(userKey=uUser, date=dDay, fields=fields,
                                                    pageToken=page_token)
            results = execute_request_with_retries(request)
            user_usage = results.get('usageReports', [])
            if 'nextPageToken' in results:
                page_token = results['nextPageToken']
                logging.info("We have {} user_usage rows, and more to come".format(len(user_usage)))
                yield user_usage
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnUserUsageReport !")
            break
    logging.info("We have {} user_usage rows in the end".format(len(user_usage)))
    yield user_usage


# Review and delete ?
# Returns Audit Log Report
# Parameters:
# uUser = User parameter or all for al users
# appName = Defined app from the reports (admin, calendar, drive, groups, login, mobile, token)
# dDay = A given date
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates an Activities Report for a given day -5 (Due to data availability)
#
# Returns: JSON with the User Usage Metrics

def returnAuditLogReport(uUser, appName, dDay, SAJson, SADelegated):
    startTime = dDay + 'T00:00:00.000Z'
    endTime = dDay + 'T23:59:59.999Z'
    page_token = None
    reports = createReportObject(cfg['scopes']['audit_log'], 'admin', 'reports_v1', SAJson, SADelegated)
    fields = 'items(actor,events,id),nextPageToken'
    while True:
        try:
            request = reports.activities().list(userKey=uUser, applicationName=appName, startTime=startTime,
                                                endTime=endTime, fields=fields, pageToken=page_token)
            results = execute_request_with_retries(request)
            activities = results.get('items', [])
            if 'nextPageToken' in results:
                page_token = results['nextPageToken']
                logging.info("We have {} activities, and more to come".format(len(activities)))
                yield activities
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnAuditLogReport!")
            break
    logging.info("We have {} activities in the end".format(len(activities)))
    yield activities


# Writes Data in BigQuery
# Parameters:
# dataRows = rows of JSON data to be written in BigQuery
# dataTable = table in BigQuery to write in
#
# Gets a JSON dataset  and splits in rows to write in BigQuery
#
# Returns: BigQuery response

def writeDatainBigQuery(dataRows, dataTable):
    bQService = createBigQueryService(cfg['scopes']['big_query'], 'bigquery', 'v2')
    logging.info("Processing {len} rows, destinated to {table}".format(len=len(dataRows), table=dataTable))
    rows_list = []
    responses = []
    for index, row in enumerate(dataRows):
        rows_list.append(row)
        if (index + 1) % 500 == 0:
            responses.append(stream_row_to_bigquery(bQService, dataTable, rows_list))
            rows_list = []
    if len(dataRows) % 500 > 0:
        responses.append(stream_row_to_bigquery(bQService, dataTable, rows_list))
    return responses


def delete_table_big_query(table_name):
    bigquery = createBigQueryService(cfg['scopes']['big_query'], 'bigquery', 'v2')
    logging.info("Deleting {table}".format(table=table_name))
    try:
        bigquery.tables().delete(
            projectId=cfg['ids']['project_id'],
            datasetId=cfg['ids']['dataset_id'],
            tableId=table_name
        ).execute()
    except Exception as err:
        logging.error(err)


# Streams Row to BigQuery
# Parameters:
# bigquery = BigQuery service
# row = a row of JSON data
#
# Streams one row of JSON data into BigQuery
#
# Returns: Nothing

def stream_row_to_bigquery(bigquery, table_name, rows):
    logging.info("Streaming {len} rows, destinated to {table}".format(len=len(rows), table=table_name))
    rows_list = []
    for row in rows:
        rows_list.append({
            'json': row,
            # Generate a unique id for each row so retries don't accidentally
            # duplicate insert
            'insertId': (hashlib.md5(str(row))).hexdigest(),
        })
    insert_all_data = {
        'skipInvalidRows': True,
        'ignoreUnknownValues': True,
        'rows': rows_list
    }
    try:
        retried = 0
        while retried < 5:
            try:
                retried += 1
                bqstream = bigquery.tabledata().insertAll(
                    projectId=cfg['ids']['project_id'],
                    datasetId=cfg['ids']['dataset_id'],
                    tableId=table_name,
                    body=insert_all_data).execute(num_retries=5)
                insertErrors = bqstream.get('insertErrors')
                break
            except Exception as err:
                if retried == 5:
                    raise err
                logging.info("Retrying streaming!")
                time.sleep(5)

        if insertErrors:
            logging.error(insertErrors)
    except Exception as err:
        logging.error(err)
        bqstream = ''
    except:
        bqstream = ''
    return bqstream


# Returns User List Extended
# Parameters:
# dDomain = Google Apps Domain
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a list of users in a given GAps domain
#
# Returns: JSON list of users, for a give date, with the defined fields

def returnUsersListGeneratorExtended(dDomain, SAJson, SADelegated):
    users = []
    page_token = None
    reports = createReportObject(cfg['scopes']['admin_directory'], 'admin', 'directory_v1', SAJson, SADelegated)
    # AVAILABLE FIELDS: https://developers.google.com/admin-sdk/directory/v1/reference/users#resource
    fields = 'nextPageToken,users'
    while True:
        try:
            request = reports.users().list(domain=dDomain, pageToken=page_token, maxResults=5,
                                           projection='full',
                                           fields=fields)
            results = execute_request_with_retries(request)
            users = results['users']
            for user_item in users:
                user_item[u'date'] = dDate
            if 'nextPageToken' in results:
                page_token = results['nextPageToken']
                logging.info("We have {} user rows, and more to come".format(len(users)))
                yield users
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnUsersListGeneratorExtended!")
            break
    logging.info("We have {} user rows in the end".format(len(users)))
    yield users

# Returns User List Token
# Parameters:
# dDomain = Google Apps Domain
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a list of users in a given GAps domain
#
# Returns: JSON list of users, for a give date, with the defined fields

def returnUsersListToken(dDomain, SAJson, SADelegated, page_token):
    dDate = date.today().strftime("%Y-%m-%d")
    try:
        reports = createReportObject(cfg['scopes']['admin_directory'], 'admin', 'directory_v1', SAJson, SADelegated)
    except Exception as err:
        bvi_log(date=dDate, resource='users_list', message_id='invalid_credential', message=err, regenerate=True)
        raise err

    # AVAILABLE FIELDS: https://developers.google.com/admin-sdk/directory/v1/reference/users#resource
    fields = 'nextPageToken'
    tokens = []
    while True:
        try:
            if page_token == '':
                request = reports.users().list(domain=dDomain, maxResults=maxResultsPage, fields=fields)
            else:
                request = reports.users().list(domain=dDomain, pageToken=page_token, maxResults=maxResultsPage,
                                               fields=fields)
            results = execute_request_with_retries(request)

            if 'nextPageToken' in results:
                tokens = results['nextPageToken']
                page_token = results['nextPageToken']
                yield tokens
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnUsersListToken!")
            bvi_log(date=dDate, resource='users_list', message_id='users_list_api_token', message=err, regenerate=True)
            tokens = []
            break
    yield tokens

# Returns User List Page Token
# Parameters:
# dDomain = Google Apps Domain
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a list of users in a given GSuite domain
#
# Returns: JSON list of users, for a give date, with the defined fields

def returnUserListPageToken(token, dDay, dDomain, SAJson, SADelegated):
    dDate = dDay
    page_token = token
    users = []
    try:
        reports = createReportObject(cfg['scopes']['admin_directory'], 'admin', 'directory_v1', SAJson, SADelegated)
    except Exception as err:
        bvi_log(date=dDate, resource='users_list', message_id='invalid_credential', message=err, regenerate=True)
        raise err

    # AVAILABLE FIELDS: https://developers.google.com/admin-sdk/directory/v1/reference/users#resource
    fields = 'nextPageToken,users(creationTime,customerId,emails,lastLoginTime,orgUnitPath,primaryEmail)'
    try:
        if page_token == '':
            request = reports.users().list(domain=dDomain, maxResults=maxResultsPage, fields=fields)
        else:
            request = reports.users().list(domain=dDomain, pageToken=page_token, maxResults=maxResultsPage,
                                           fields=fields)
        results = execute_request_with_retries(request)
        users = results['users']
        for user_item in users:
            user_item[u'date'] = dDate
    except DeadlineExceededError as err:
        logging.error(err)
        logging.error("Retrying!")
    except Exception as err:
        logging.error(err)
        logging.error("Error Found, ending returnUserListPageToken!")
        bvi_log(date=dDate, resource='users_list', message_id='users_list_api', message=err, regenerate=True)
    logging.info("We have {} user rows in the end".format(len(users)))
    yield users


# Returns User Usage Token
# Parameters:
# dDay = A given date
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a User Usage Report for a given day -3 (Due to data availability)
#
# Returns: JSON with list of page tokens

def returnUserUsageToken(dDay, SAJson, SADelegated, page_token):
    tokens = []
    try:
        reports = createReportObject(cfg['scopes']['admin_report'], 'admin', 'reports_v1', SAJson, SADelegated)
    except Exception as err:
        bvi_log(date=dDay, resource='user_usage', message_id='invalid_credential', message=err, regenerate=True)
        raise err
    # AVAILABLE FIELDS: https://developers.google.com/admin-sdk/reports/v1/reference/usage-ref-appendix-a/users
    fields = 'nextPageToken'
    pages = 0
    while True:
        try:
            if page_token == '':
                request = reports.userUsageReport().get(userKey='all', date=dDay, fields=fields,
                                                        maxResults=maxResultsPage_UserUsage)
            else:
                request = reports.userUsageReport().get(userKey='all', date=dDay, fields=fields,
                                                        pageToken=page_token,
                                                        maxResults=maxResultsPage_UserUsage)
            results = execute_request_with_retries(request)
            pages += 1
            if 'nextPageToken' in results:
                tokens = results['nextPageToken']
                page_token = results['nextPageToken']
                yield tokens
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnUserUsageToken !")
            tokens = []
            bvi_log(date=dDay, resource='user_usage', message_id='user_usage_api', message=err, regenerate=True)
            break
    logging.info("We have {} user_usage pages in the end".format(pages))
    logging.info(tokens)
    yield tokens

# Returns User Usage Report Page Token
# Parameters:
# dDomain = Google Apps Domain
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a User Usage Report for a given day -3 (Due to data availability)
#
# Returns: JSON with the User Usage Metrics

def returnUserUsagePageToken(token, dDay, SAJson, SADelegated):
    dDate = dDay
    page_token = token
    user_usage = []
    try:
        reports = createReportObject(cfg['scopes']['admin_report'], 'admin', 'reports_v1', SAJson, SADelegated)
    except Exception as err:
        bvi_log(date=dDay, resource='user_usage', message_id='invalid_credential', message=err, regenerate=True)
        raise err
    # AVAILABLE FIELDS: https://developers.google.com/admin-sdk/reports/v1/reference/usage-ref-appendix-a/users
    fields = 'nextPageToken,usageReports(date,entity,parameters)'
    try:
        if page_token == '':
            request = reports.userUsageReport().get(userKey='all', date=dDay, fields=fields,
                                                    maxResults=maxResultsPage_UserUsage)
        else:
            request = reports.userUsageReport().get(userKey='all', date=dDay, fields=fields,
                                                    pageToken=page_token, maxResults=maxResultsPage_UserUsage)
        results = execute_request_with_retries(request)
        user_usage = results.get('usageReports', [])
    except Exception as err:
        logging.error(err)
        logging.error("Error Found, ending returnUserUsagePageToken!")
        bvi_log(date=dDay, resource='user_usage', message_id='user_usage_api', message=err, regenerate=True)
    logging.info("We have {} user_usage rows in the end".format(len(user_usage)))
    yield user_usage

# Returns Activities Token
# Parameters:
# dDay = A given date
# appName
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a Activities Report for a given day -3 (Due to data availability) and App
#
# Returns: JSON with list of page tokens

def returnActivitiesToken(dDay, appName, SAJson, SADelegated, page_token):
    tokens = []
    startTime = dDay + 'T00:00:00.000Z'
    endTime = dDay + 'T23:59:59.999Z'
    try:
        reports = createReportObject(cfg['scopes']['audit_log'], 'admin', 'reports_v1', SAJson, SADelegated)
    except Exception as err:
        bvi_log(date=dDay, resource='activities', message_id='invalid_credential', message=err, regenerate=True)
        raise err
    fields = 'nextPageToken'
    while True:
        try:
            if page_token == '':
                request = reports.activities().list(userKey='all', applicationName=appName, startTime=startTime,
                                                    endTime=endTime, fields=fields, maxResults=maxResultsPage)
            else:
                request = reports.activities().list(userKey='all', applicationName=appName, startTime=startTime,
                                                    endTime=endTime, fields=fields, pageToken=page_token,
                                                    maxResults=maxResultsPage)
            results = execute_request_with_retries(request)

            if 'nextPageToken' in results:
                tokens = results['nextPageToken']
                page_token = results['nextPageToken']
                yield tokens
            else:
                break
        except DeadlineExceededError as err:
            logging.error(err)
            logging.error("Retrying!")
        except Exception as err:
            logging.error(err)
            logging.error("Error Found, ending returnActivitiesToken !")
            tokens = []
            bvi_log(date=dDay, resource='activities', message_id='activities_api', message=err, regenerate=True)
            break
    yield tokens

# Returns Activities Report Page Token
# Parameters:
# token
# appName
# dDomain = Google Apps Domain
# SAJson = Service Account Json Authentication File
# SADelegated = SuperAdmin Delegated Account
#
# Generates a Activities Report for a given day -3 (Due to data availability) and App
#
# Returns: JSON with the User Usage Metrics

def returnActivitiesPageToken(token, appName, dDay, SAJson, SADelegated):
    startTime = dDay + 'T00:00:00.000Z'
    endTime = dDay + 'T23:59:59.999Z'
    page_token = token
    activities = []
    try:
        reports = createReportObject(cfg['scopes']['audit_log'], 'admin', 'reports_v1', SAJson, SADelegated)
    except Exception as err:
        bvi_log(date=dDay, resource='activities', message_id='invalid_credential', message=err, regenerate=True)
        raise err
    # AVAILABLE FIELDS: https://developers.google.com/admin-sdk/reports/v1/reference/activity-ref-appendix-a/admin-event-names and more.
    fields = 'items(actor,events,id),nextPageToken'
    try:
        if page_token == '':
            request = reports.activities().list(userKey='all', applicationName=appName, startTime=startTime,
                                                endTime=endTime, fields=fields, maxResults=maxResultsPage)
        else:
            request = reports.activities().list(userKey='all', applicationName=appName, startTime=startTime,
                                                endTime=endTime, fields=fields, pageToken=page_token,
                                                maxResults=maxResultsPage)
        results = execute_request_with_retries(request)
        logging.info(results)
        activities = results.get('items', [])
    except Exception as err:
        logging.error(err)
        logging.error("Error Found, ending returnActivitiesPageToken!")
        bvi_log(date=dDay, resource='activities', message_id='activities_api', message=err, regenerate=True)
    logging.info("We have {} activities rows in the end".format(len(activities)))
    yield activities


def get_dateref_or_from_cron(dateref):
    if dateref == "from_cron":
        report_date = date.today() - timedelta(days=4)
        dateref = report_date.strftime("%Y-%m-%d")
    return dateref

class PrintMain(webapp2.RequestHandler):
    def get(self):
        logging.info('Main')
        self.response.write(cfg['version'])
        self.response.write("<p>Task Max Pages: {}</p>".format(cfg['task_management']['max_pages']))
        self.response.write("<p>Task Page Size: {}</p>".format(cfg['task_management']['page_size']))
        if cfg['plan'] == 'Business':
            self.response.write("<p>Task Page Size User_Usage: {}</p>".format(cfg['task_management']['page_size_user_usage']))

application = webapp2.WSGIApplication([('/', PrintMain)],
                                      debug=True)