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
    printf "Usage: %s dataset table_name YYYYMMDD\n" $0
    printf "\t%s\tThe dataset for the table\n" 'dataset'
    printf "\t%s\tThe name of the table\n" 'table_name'
    printf "\t%s\tThe partition to be trucanted\n" 'YYYYMMDD'
}

if [[ $# -lt 3 ]]; then
  usage
  exit 1
fi

dataset=${1}
table=${2}
YYYYMMDD=${3}

printf "Truncating $dataset.$table for partition $YYYYMMDD in proyect ${DEVSHELL_PROJECT_ID}\n"

bq query --replace --noflatten_results --allow_large_results --noflatten_results --allow_large_results --destination_table=${dataset}.$table\$$YYYYMMDD "SELECT * FROM [${DEVSHELL_PROJECT_ID}:$dataset.$table] WHERE _PARTITIONTIME=DATE_ADD(CURRENT_DATE(),1,'DAY')"