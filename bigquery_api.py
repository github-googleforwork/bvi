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

# Author: Julio Quinteros
# Enhanced by Ismael Yuste

# This file adds all the needed features to work with BigQuery
# Implements PrintBigQuery to create datasets, tables and views authomatically for the project
# async_query
# create_dataset
# create_empty_table
# create_view
# do_create_table
# do_create_view
# exists_dataset
# exists_table_or_view
# list_datasets
# poll_job


import yaml
import logging
import webapp2
import random
import sys
import time
import uuid
import datetime

from bigquery_custom_schemas_cfg import setup as bigquery_custom_schemas_setup
from main import createBigQueryService, get_dateref_or_from_cron
from googleapiclient.errors import HttpError as gHttpError
from six.moves.urllib.error import HTTPError
from httplib import HTTPException
from pprint import pprint, pformat
from google.appengine.api import taskqueue
from bvi_logger import bvi_log
from bigquery_survey_cfg import setup as bigquery_survey_setup
from bigquery_logs_cfg import setup as bigquery_logs_setup
from bigquery_billing_cfg import setup as bigquery_billing_setup

from google.appengine.api import urlfetch
urlfetch.set_default_fetch_deadline(600)

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)

if cfg['plan'] == 'Enterprise':
    from bigquery_cfg_esku import setup as bigquery_setup
else:
    from bigquery_cfg import setup as bigquery_setup



# [START async_query]
# Changed WRITE_APPEND with WRITE_TRUNCATE on 170613 to empty table partition while update
def async_query(
        bigquery, project_id, query,
        destination_dataset, destination_table,
        batch=False, num_retries=5, use_legacy_sql=True):
    # Generate a unique job ID so retries
    # don't accidentally duplicate query
    job_data = {
        'jobReference': {
            'projectId': project_id,
            'jobId': str(uuid.uuid4())
        },
        'configuration': {
            'query': {
                'query': query,
                'priority': 'BATCH' if batch else 'INTERACTIVE',
                # Set to False to use standard SQL syntax. See:
                # https://cloud.google.com/bigquery/sql-reference/enabling-standard-sql
                'useLegacySql': use_legacy_sql,
                'allowLargeResults': True,
                "destinationTable": {
                      "projectId": cfg['ids']['project_id'],
                      "datasetId": destination_dataset,
                      "tableId": destination_table
                },
                "schemaUpdateOptions": "ALLOW_FIELD_ADDITION",
                "createDisposition": "CREATE_IF_NEEDED",
                "writeDisposition": "WRITE_TRUNCATE",
            }
        }
    }
    return bigquery.jobs().insert(
        projectId=project_id,
        body=job_data).execute(num_retries=num_retries)
# [END async_query]


def fetch_big_query_table_info(bigquery, project_id, dataset_id, table_id):

    info = {}

    try:
        info = bigquery.tables().get(
            projectId=project_id,
            datasetId=dataset_id,
            tableId=table_id).execute(num_retries=5)
    except Exception:
        logging.info("The info requested for {}:{}.{} was not found.".format(project_id, dataset_id, table_id))

    return info


def fetch_big_query_data(bigquery, project_id, query, num_attempts):

    query_body = {
        "timeoutMs": 180000,
        "useQueryCache": False,
        "query": query
    }

    result = bigquery.jobs().query(
        projectId=project_id,
        body=query_body).execute()

    job_finished = bool(result['jobComplete'])
    job_id = result['jobReference']['jobId']
    current_try = 1

    while not job_finished and current_try <= num_attempts:
        logging.info("Number of attempt to poll the query result [{}] of [{}].".format(current_try, num_attempts))

        result = bigquery.jobs().getQueryResults(
            projectId=project_id,
            jobId=job_id,
            timeoutMs=180000).execute()

        job_finished = bool(result['jobComplete'])

        current_try += 1

    if not job_finished:
        logging.info("The job for the query requested has not been completed.")
        raise Exception("Query job requested not finished")

    return result


def convert_big_query_result(result, bq_entity):
    rows = []

    for row in result['rows']:
        converted_row = {}
        for index_v, value in enumerate(row['f']):
            converted_row[bq_entity[str(index_v+1)]] = value['v']
        rows.append(converted_row)

    return rows


def set_external_data_configuration(table_data, external_data_configuration):

    if cfg['google_sheets_link'] or cfg['custom_fields_sheets_link']:
        link = ''

        if table_data['tableReference']['tableId'] == 'raw_form_responses':
            link = cfg['google_sheets_link']
        elif table_data['tableReference']['tableId'] == 'custom_fields':
            link = cfg['custom_fields_sheets_link']

        table_data['externalDataConfiguration'] = external_data_configuration
        table_data['externalDataConfiguration']['sourceUris'][0] = \
            table_data['externalDataConfiguration']['sourceUris'][0].replace(
                "YOUR_GOOGLE_SHEETS_LINK", link)
    else:
        table_data['schema'] = external_data_configuration['schema']


def create_dataset(
    bigquery, project_id, description,
    destination_dataset,
    num_retries=5):
    try:
        dataset_data = {
            'datasetReference':{
                'projectId': project_id,
                'datasetId': destination_dataset
            },
            'description': description,
        }
        return bigquery.datasets().insert(
            projectId=project_id, body=dataset_data).execute(num_retries=num_retries)

    except gHttpError as err:
        if err.resp.status in [409]:
            pass
    except HTTPError as err:
        logging.error('Error in create_dataset: %s' % err.content)
        raise err


def create_empty_table(
    bigquery, project_id,
    destination_dataset, destination_table,
    schema=None, description=None, timePartitioning=None,
    externalDataConfiguration=None, num_retries=5):

    try:
        table_data = {
            'tableReference':{
                'projectId': project_id,
                'tableId': destination_table,
                'datasetId': destination_dataset
            },
        }
        if schema:
            table_data['schema'] = schema
        if description:
            table_data['description'] = description
        if timePartitioning:
            table_data['timePartitioning'] = timePartitioning
        if externalDataConfiguration:
            set_external_data_configuration(table_data, externalDataConfiguration)

        logging.info('======================= TABLE:\n %s', table_data)

        return bigquery.tables().insert(
            projectId=project_id, datasetId=destination_dataset,
            body=table_data).execute(num_retries=num_retries)

    except gHttpError as err:
        if err.resp.status in [409]:
            pass
    except HTTPError as err:
        logging.error('Error in create_empty_table: %s' % err.content)
        raise err


def create_view(
    bigquery, project_id, query,
    destination_dataset, destination_table,
    num_retries=5,use_legacy_sql=True, overwrite=False):

    try:
        view_data = {
            'tableReference':{
                'projectId': project_id,
                'tableId': destination_table,
                'datasetId': destination_dataset
            },
            'view': {
                'query': query,
                'useLegacySql': use_legacy_sql,
            }
        }

        retried = 0
        while retried < num_retries:
            try:
                retried += 1
                if overwrite:
                    try:
                        bigquery.tables().delete(projectId=project_id, datasetId=destination_dataset,
                                             tableId=destination_table).execute(num_retries=num_retries)
                    except Exception as err:
                        logging.info('Not needed to delete view, it does not exist: %s', destination_table)

                return bigquery.tables().insert(
                    projectId=project_id, datasetId=destination_dataset,
                    body=view_data).execute(num_retries=num_retries)
            except HTTPException as err:
                logging.error(err)
                logging.error("Retrying!")

    except gHttpError as err:
        if err.resp.status in [409]:
            pass
    except HTTPError as err:
        logging.error('Error in create_view: %s' % err.content)
        raise err

def do_create_table(self, bigquery, table_def):
    try:
        if not exists_table_or_view(
                bigquery,
                cfg['ids']['project_id'],
                destination_dataset=table_def['dataset'],
                destination_table=table_def['name'],
                num_retries=5):
            try:
                create_empty_table(
                    bigquery,
                    cfg['ids']['project_id'],
                    destination_dataset=table_def['dataset'],
                    destination_table=table_def['name'],
                    schema=table_def.get('schema'),
                    description=table_def.get('description'),
                    timePartitioning=table_def.get('timePartitioning'),
                    externalDataConfiguration=table_def.get('externalDataConfiguration'),
                    num_retries=5)
                operation = "created"
                salida = "<b>{destination_dataset}.{destination_table}</b> ... {operation}!".format(
                    destination_dataset=table_def['dataset'],
                    destination_table=table_def['name'],
                    operation=operation
                )
                self.response.write(salida)
                self.response.write("<hr/>")
            except gHttpError as err:
                logging.error("Cant create {table}".format(table=table_def['name']))
                return
            except HTTPError as err:
                logging.error("Cant create {table}".format(table=table_def['name']))
                return
        else:
            salida = "<b>{destination_dataset}.{destination_table}</b> already exists <br><hr/>".format(
                    destination_dataset=table_def['dataset'],
                    destination_table=table_def['name']
                )
            self.response.write(salida)

    except HTTPError as err:
        logging.error('Error in get: %s' % err.content)


def do_create_view(self, bigquery, folder, view_dataset, view_name, table_from_view=False, overwrite=False, timestamp=None, decoratorDate=None):

    if timestamp is None:
        timestamp = "DATE_ADD(TIMESTAMP(CURRENT_DATE()),1,'DAY')"
    else:
        timestamp = "TIMESTAMP('{timestamp}')".format(timestamp=timestamp)

    domains = list(set(cfg['domains'].split(";")))
    domains_str = "'" + "', '".join(map(str.strip, domains)) + "'"

    query_fp = open('{folder}/{dataset}/{name}.sql'.format(folder=folder, dataset=view_dataset, name=view_name), 'r')
    query_string = query_fp.read()
    query_string = query_string.replace("YOUR_PROJECT_ID", cfg['ids']['project_id'])
    if cfg['export_dataset']:
        query_string = query_string.replace("EXPORT_DATASET", cfg['export_dataset'])
    query_string = query_string.replace("YOUR_DOMAINS", domains_str)

    query_string = query_string.replace("YOUR_TIMESTAMP_PARAMETER", timestamp)
    query_fp.close()

    logging.debug(query_string)

    if decoratorDate:
        view_name = "{view_name}${decoratorDate}".format(view_name=view_name, decoratorDate=decoratorDate)

    try:
        if overwrite==True or exists_table_or_view(
                bigquery,
                cfg['ids']['project_id'],
                destination_dataset=view_dataset,
                destination_table=view_name,
                num_retries=5) == False:
            if table_from_view==True:
                query_job = async_query(
                    bigquery,
                    cfg['ids']['project_id'],
                    query_string,
                    destination_dataset=view_dataset,
                    destination_table=view_name,
                    batch=False, num_retries=5, use_legacy_sql=True)

                if overwrite:
                    operation = "updated"
                else:
                    operation = "created"
                salida = "<b>{destination_dataset}.{destination_table}</b> ... {operation} ... ".format(
                    destination_dataset=view_dataset,
                    destination_table=view_name,
                    operation=operation
                )
                self.response.write(salida)
                poll_job(bigquery, query_job, self)
                self.response.write("<hr/>")

            elif table_from_view==False:
                try:
                    create_view(
                        bigquery,
                        cfg['ids']['project_id'],
                        query_string,
                        destination_dataset=view_dataset,
                        destination_table=view_name,
                        num_retries=5,
                        use_legacy_sql=True,
                        overwrite=overwrite)
                    if overwrite:
                        operation = "updated"
                    else:
                        operation = "created"
                    salida = "<b>{destination_dataset}.{destination_table}</b> ... {operation}!".format(
                        destination_dataset=view_dataset,
                        destination_table=view_name,
                        operation=operation
                    )
                    self.response.write(salida)
                    self.response.write("<hr/>")

                except gHttpError as err:
                    logging.error("Cant create {view}".format(view=view_name))
                    return
                except HTTPError as err:
                    logging.error("Cant create {view}".format(view=view_name))
                    return
        else:
            salida = "<b>{destination_dataset}.{destination_table}</b> already exists <br><hr/>".format(
                    destination_dataset=view_dataset,
                    destination_table=view_name
                )
            self.response.write(salida)

    except HTTPError as err:
        logging.error('Error in get: %s' % err.content)

def exists_dataset(
    bigquery, project_id,
    destination_dataset,
    num_retries=5):
    try:
        bigquery.datasets().get(projectId=project_id,
            datasetId=destination_dataset).execute()
        return True
    except gHttpError as err:
        if err.resp.status in [409]:
            return True
        return False
    except HTTPError as err:
        if err.resp.stats != 404:
            raise err
        return False


def exists_table_or_view(
    bigquery, project_id,
    destination_dataset, destination_table,
    num_retries=5):
    try:
        bigquery.tables().get(projectId=cfg['ids']['project_id'],
            datasetId=destination_dataset, tableId=destination_table).execute()
        return True
    except gHttpError as err:
        if err.resp.status in [409]:
            return True
        return False
    except HTTPError as err:
        if err.resp.stats != 404:
            raise err
        return False


# [START list_datasets]
def list_datasets(bigquery, project=None):
    try:
        datasets = bigquery.datasets()
        list_reply = datasets.list(projectId=project).execute()
        logging.info('Dataset list:')
        pprint(list_reply)
        return pformat(list_reply, indent=4)

    except HTTPError as err:
        logging.error('Error in list_datasets: %s' % err.content)
        raise err
# [END list_datasets]


# [START list_projects]
def list_projects(bigquery):
    try:
        projects = bigquery.projects()
        list_reply = projects.list().execute()

        logging.info('Project list:')
        pprint(list_reply)
        return pformat(list_reply, indent=4)

    except HTTPError as err:
        logging.error('Error in list_projects: %s' % err.content)
        raise err
# [END list_projects]

# [START poll_job]
def poll_job(bigquery, job, self):
    """Waits for a job to complete."""

    logging.info('Waiting for job to finish...')

    request = bigquery.jobs().get(
        projectId=job['jobReference']['projectId'],
        jobId=job['jobReference']['jobId'])

    while True:
        result = request.execute(num_retries=2)

        if result['status']['state'] == 'DONE':
            if 'errorResult' in result['status']:
                self.response.write("{error}<br/>".format(error=result['status']['errorResult']))
                logging.error(result['status']['errorResult'])
            else:
                self.response.write('DONE!<br/>')
                logging.info('Job complete.')
            return

        time.sleep(1)
# [END poll_job]


def create_tables_from_list(self, bigquery, folder, tables_list, op):
    start = self.request.get('start')
    end = self.request.get('end')

    if len(start) > 0 and len(end) > 0 and type(int(start)) is int and type(int(end)) is int:
        logging.info("Creating tables between {start} and {end}".format(start=start, end=end))
        digits = len(str(len(tables_list)))
        for index, table_def in enumerate(tables_list):
            if int(start) <= index <= int(end):
                logging.info("Creating table {index:0{digits}}: {name}".format(digits=digits, index=index,
                                                                               name=table_def['name']))
                if table_def['type'] == 'table':
                    do_create_table(self, bigquery, table_def)
                elif table_def['type'] == 'table_from_view':
                    if table_def.get('timePartitioning'):
                        do_create_table(self, bigquery, table_def)
                    do_create_view(self, bigquery, folder, table_def['dataset'], table_def['name'], True, overwrite=True)
                elif table_def['type'] == 'view':
                    do_create_view(self, bigquery, folder, table_def['dataset'], table_def['name'], False)
    else:
        digits = len(str(len(tables_list)))
        tables_set = []
        start = 0
        end = 0
        amount = 5
        self.response.write("There are {} tables available<br/><hr/>".format(len(tables_list)))
        for index, table_def in enumerate(tables_list):
            tables_set.append("{dataset}.{name}".format(dataset=table_def.get('dataset'), name=table_def.get('name')))
            if (index + 1) % amount == 0:
                start = index + 1 - amount
                end = index
                salida = "<a href='{base}?op={op}&start={start}&end={end}' target='_blank'>{start_plusone:0{digits}}-{end_plusone:0{digits}}</a> ({tables})<br/>".format(
                    base="/bq_api", op=op, start=start, end=end, start_plusone=start + 1,
                    end_plusone=end + 1, digits=digits, tables=", ".join(tables_set))
                self.response.write(salida)
                tables_set = []

        number_tables = len(tables_list)

        if number_tables % amount > 0:
            start = end + 1 if number_tables > amount else 0
            end = len(tables_list) - 1 if number_tables > amount else number_tables
            salida = "<a href='{base}?op={op}&start={start}&end={end}' target='_blank'>{start_plusone:0{digits}}-{end_plusone:0{digits}}</a> ({tables})<br/>".format(
                base="/bq_api", op=op, start=start, end=end, start_plusone=start + 1, end_plusone=end + 1,
                digits=digits, tables=", ".join(tables_set))
            self.response.write(salida)



def recreate_views(self, bigquery, folder, tables_list, op):
    start = self.request.get('start')
    end = self.request.get('end')
    views_list = [x for x in tables_list if x['type'] == 'view']

    if len(start) > 0 and len(end) > 0 and type(int(start)) is int and type(int(end)) is int:
        logging.info("Recreating views between {start} and {end}".format(start=start, end=end))
        digits = len(str(len(views_list)))
        for index, view_def in enumerate(views_list):
            if int(start) <= index <= int(end):
                logging.info("Recreating view {index:0{digits}}: {name}".format(digits=digits, index=index,
                                                                               name=view_def['name']))
                do_create_view(self, bigquery, folder, view_def['dataset'], view_def['name'], False, True)

    else:
        digits = len(str(len(views_list)))
        views_set = []
        end = 0
        amount = 5
        self.response.write("There are {} views available<br/><hr/>".format(len(views_list)))
        for index, view_def in enumerate(views_list):
            views_set.append("{dataset}.{name}".format(dataset=view_def.get('dataset'), name=view_def.get('name')))
            if (index + 1) % amount == 0:
                start = index + 1 - amount
                end = index
                salida = "<a href='{base}?op={op}&start={start}&end={end}' target='_blank'>{start_plusone:0{digits}}-{end_plusone:0{digits}}</a> ({tables})<br/>".format(
                    base="/bq_api", op=op, start=start, end=end, start_plusone=start + 1,
                    end_plusone=end + 1, digits=digits, tables=", ".join(views_set))
                self.response.write(salida)
                views_set = []

        number_views = len(views_list)

        if number_views % amount > 0:
            start = end + 1 if number_views > amount else 0
            end = len(views_list) - 1 if number_views > amount else number_views
            salida = "<a href='{base}?op={op}&start={start}&end={end}' target='_blank'>{start_plusone:0{digits}}-{end_plusone:0{digits}}</a> ({tables})<br/>".format(
                base="/bq_api", op=op, start=start, end=end, start_plusone=start + 1, end_plusone=end + 1,
                digits=digits, tables=", ".join(views_set))
            self.response.write(salida)


def update_data_level(self, bigquery, op, bigquery_setup):

    level = self.request.get('level')
    target = self.request.get('target')
    dateref = self.request.get('dateref')
    logging.info("update {} {} {}".format(level, target, dateref))

    try:
        dateref = get_dateref_or_from_cron(dateref)
        yyyy, mm, dd = dateref.split("-")
        timestamp = datetime.datetime(int(yyyy), int(mm), int(dd))
    except ValueError:
        logging.error("Wrong updating date = {dateref}".format(dateref=dateref))
        self.response.write("Wrong updating date = {}".format(dateref))
        return

    if level_is_valid(level) or len(target) > 0:
        if level_is_valid(level) and not target:
            # only first time
            bvi_log(date=dateref, resource='bq_{op}_level{level}'.format(op=op, level=level), message_id='start',
                    message='Start of /bq_api call')
        for index, table_def in enumerate(bigquery_setup['tables']):
            if target:
                target_dataset, target_name = target.split(".")
                if target_dataset is None or target_name is None:
                    logging.error("Wrong target {target}".format(target=target))
                    self.response.write("Wrong target {target}".format(target=target))
                    if level_is_valid(level):
                        bvi_log(date=dateref, resource='bq_{op}_level{level}'.format(op=op, level=level),
                                message_id='bq_api_wrong_target', message="Wrong dataset/table target", regenerate=True)
                    return
                elif table_def.get('dataset') == target_dataset and table_def.get('name') == target_name:
                    logging.info("Request for updating {}".format(target_name))
                    decoratorDate = None
                    if table_def.get('timePartitioning'):
                        decoratorDate = "{yyyy}{mm}{dd}".format(yyyy=yyyy, mm=mm, dd=dd)
                    try:
                        do_create_view(self, bigquery, bigquery_setup['folder'], table_def['dataset'],
                                       "{table}".format(table=table_def['name']), True, overwrite=True,
                                       timestamp=timestamp, decoratorDate=decoratorDate)
                    except Exception as err:
                        bvi_log(date=dateref, resource='bq_{op}_level{level}'.format(op=op, level=level),
                                message_id='bigquery_error', message=err, regenerate=True)
                        raise err
            elif table_def.get('level') and str(table_def.get('level')) == str(level):

                logging.info("Request for updating {} (massive level {} update)".format(table_def.get('name'), level))

                queue_name = "bqUpdateByLevel{level}".format(level=level)
                tNow = datetime.datetime.now()
                aNumber = tNow.strftime("%S")
                aRandomNumber = random.randint(0, sys.maxsize)
                aNumber = "{aNumber}_{aRandomNumber}".format(aNumber=aNumber, aRandomNumber=aRandomNumber)

                task = taskqueue.add(queue_name=queue_name,
                                     name='bqupdate_level_' + level + '_' + aNumber + '-' + table_def.get(
                                         'dataset') + 'DOT' + table_def.get('name'),
                                     url="/bq_api?op={op}&level={level}&target={dataset}.{table}&dateref={dateref}".format(
                                         op=op, level=level, dataset=table_def.get('dataset'), table=table_def.get('name'),
                                         dateref=dateref), method='GET')
                self.response.write("Task {}<br/> for table {}.{} on {} enqueued,<br/>ETA {}<hr/>".format(task.name, table_def.get('dataset'), table_def.get('name'), dateref, task.eta))
                bvi_log(date=dateref, resource='bq_{op}_level{level}'.format(op=op, level=level), message_id='end',
                        message='End of /bq_api call')
            else:
                logging.info(
                    "Nothing to do with table {index} = {name}".format(index=index, name=table_def.get("name", "name")))
        if level_is_valid(level):
            bvi_log(date=dateref, resource='bq_{op}_level{level}'.format(op=op, level=level), message_id='end',
                    message='End of /bq_api call')
    else:
        logging.error("Wrong parameter level={level}, target={target}".format(level=level, target=target))
        self.response.write("Wrong parameter level={level}, target={target}".format(level=level, target=target))


def level_is_valid(level):
    return len(level) > 0 and type(int(level)) is int


def custom_fields_empty(bigquery):

    project_id = cfg['ids']['project_id']
    dataset_id = 'custom'
    table_id = 'raw_custom_fields'

    info = fetch_big_query_table_info(bigquery, project_id, dataset_id, table_id)

    logging.info('Table info: {}'.format(info))

    is_empty = True
    if ('externalDataConfiguration' in info) and info['externalDataConfiguration']['sourceFormat'] == 'GOOGLE_SHEETS':
        logging.info("Custom Fields table is set with external GOOGLE_SHEETS config.")
        is_empty = False

    if ('numRows' in info) or int(info['numRows']) > 0:
        logging.info("Custom Fields table is not empty because there a rows inserted in it.")
        is_empty = False

    return is_empty


class PrintBigQuery(webapp2.RequestHandler):
    def get(self):

        op = self.request.get('op')
        scopes = cfg['scopes']['big_query']
        bigquery = createBigQueryService(scopes, 'bigquery', 'v2')

        if op == "list_projects":
            self.response.write( list_projects(bigquery) )

        elif op == "create_datasets":
            for dataset_def in bigquery_setup['datasets']:
                try:
                    destination_dataset = dataset_def['name']
                    if not exists_dataset(
                            bigquery,
                            cfg['ids']['project_id'],
                            destination_dataset=destination_dataset,
                            num_retries=5):
                        try:
                            create_dataset(
                                bigquery,
                                cfg['ids']['project_id'],
                                description=dataset_def['description'],
                                destination_dataset=destination_dataset,
                                num_retries=5)
                            salida = "<b>{destination_dataset}</b> created <br>".format(
                                    destination_dataset=destination_dataset,
                                )
                            self.response.write(salida)
                        except gHttpError as err:
                            self.response.write( "Cant create {dataset}".format(dataset=destination_dataset) )
                            return
                        except HTTPError as err:
                            self.response.write( "Cant create {dataset}".format(dataset=destination_dataset) )
                            return
                    else:
                        salida = "<b>{destination_dataset}</b> already exists <br><hr/>".format(
                                destination_dataset=destination_dataset,
                            )
                        self.response.write(salida)

                except HTTPError as err:
                    self.response.write('Error in get: %s' % err.content)

        elif op == "create_tables":
            create_tables_from_list(self=self, bigquery=bigquery, folder=bigquery_setup['folder'],
                                    tables_list=bigquery_setup['tables'], op=op)

        elif op == "create_custom_schemas":
            create_tables_from_list(self=self, bigquery=bigquery, folder=bigquery_custom_schemas_setup['folder'],
                                    tables_list=bigquery_custom_schemas_setup['tables'], op=op)

        elif op == "create_survey_tables":
            create_tables_from_list(self=self, bigquery=bigquery, folder=bigquery_survey_setup['folder'],
                                    tables_list=bigquery_survey_setup['tables'], op=op)

        elif op == "create_logs_tables":
            create_tables_from_list(self=self, bigquery=bigquery, folder=bigquery_logs_setup['folder'],
                                    tables_list=bigquery_logs_setup['tables'], op=op)

        elif op == "create_billing_view":
            create_tables_from_list(self=self, bigquery=bigquery, folder=bigquery_logs_setup['folder'],
                                    tables_list=bigquery_billing_setup['tables'], op=op)

        elif op == "recreate_views":
            recreate_views(self=self, bigquery=bigquery, folder=bigquery_setup['folder'],
                                    tables_list=bigquery_setup['tables'], op=op)

        elif op == "update":
            update_data_level(self, bigquery, 'update', bigquery_setup)
        elif op == "custom_update":
            if not custom_fields_empty(bigquery):
                update_data_level(self, bigquery, 'custom_update', bigquery_custom_schemas_setup)

        elif op == "__dir__":
            options = [
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="list_projects"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="create_datasets"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="create_tables"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api",
                                                                           op="create_survey_tables"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="create_custom_schemas"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="create_logs_tables"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="create_billing_view"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="recreate_views"),
                "<a href='{base}?op={op}' target='_blank'>{op}</a>".format(base="/bq_api", op="update"),
            ]

            salida = "<br/>".join(options)
            self.response.write(salida)

        else: #illegal option
            self.response.write("So sorry, but I didn't understand that order")

application = webapp2.WSGIApplication([('/bq_api', PrintBigQuery)],
                                      debug=True)
