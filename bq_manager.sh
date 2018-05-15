#!/bin/bash
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

# Author: Julio Quinteros

usage(){
    printf "Usage: %s [-v] dataset [view_name] [view_operation]\n" $0
    printf "\t%s\tEnables verbose mode\n" '-v'
    printf "\t%s\tThe dataset for the table\n" 'dataset'
    printf "\t%s\tThe name of the table\n" 'view_name'
    printf "\t%s\tEither 'update' or 'mk'\n" 'view_operation'
    printf "If view_name is provided, updates this view. If not, lists current status of all in dataset.\n"
    printf "This command uses bigquery folder as default location for views definitions.\n"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

verbose='false'

while getopts ':v' flag; do
  case "${flag}" in
    v) verbose='true' ;;
    *) usage
        error ${LINENO} "Unexpected option ${OPTARG}"
        ;;
  esac
done
shift "$((OPTIND-1))"

dataset=$1
BIGQUERYFOLDER='schemas/bigquery'
if [[ $# -eq 1 ]]; then
    # views=$(bq ls ${dataset} | sed -n -e 's/^[[:space:]]//; s/VIEW//p')
    # for view in $views
    for view in "$BIGQUERYFOLDER/$dataset"/*.sql
    do
        view="${view/$BIGQUERYFOLDER\/$dataset\//}"
        view="${view/\.sql/}"
        if [ -f $BIGQUERYFOLDER/${dataset}/${view}.sql ]; then
            modified=$(stat $BIGQUERYFOLDER/${dataset}/${view}.sql|sed -n -e 's/^[[:space:]]//; s/Modify://p')
            mdate=$(date --date="${modified}" +"%s")
            # day=$(date --date @${mdate} +"%d")
            # month=$(date --date @${mdate} +"%b")
            # month=$(find_month $month)
            # year=$(date +"%Y")
            # mdate=$(date -d "$year-$month-$day")
            mdatevar=$(date --date @${mdate} +"%d-%b")
            modified=$(date --date @${mdate} +"%Y %d %b %H:%M:%S")
        else
            modified="NOT FOUND"
        fi
        bq show ${dataset}.${view} |\
            awk '/-----------------/{x = NR + 1}NR == x' |\
            awk -v view="$view" -v modified="$modified" \
                -v filemodifiedvar="$mdatevar" \
                -v verbose="$verbose" \
                'BEGIN {
                    split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec",month)
                    for (i in month) {
                        month_nums[month[i]]=i
                    }
                }{
                n = split($0, t)
                modifiedbq=sprintf("%02d",month_nums[t[2]])"-"t[1]
                n = split(filemodifiedvar, filedate, "-")
                modifiedfile=sprintf("%02d",month_nums[filedate[2]])"-"filedate[1]

                comp="OK"
                if (modifiedfile > modifiedbq)
                    comp="UPDATE"
                printf "%-30s", view
                if (verbose == "true") {
                    printf "     (BQ) %-10s", sprintf("%s %s %s", t[1], t[2], t[3])
                    printf "     (REPO) %-10s", modified
                }
                printf "     %10s\n", comp
            }'
    done
else
    view=$2
    sed "s/YOUR_PROJECT_ID/${DEVSHELL_PROJECT_ID=}/g;" $BIGQUERYFOLDER/${dataset}/${view}.sql > query.sql
    query=$(<query.sql)
    op=${3:-"update"}
    bq $op --view="$query" $dataset.$view
    rm query.sql
fi

