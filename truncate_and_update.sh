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
    printf "Usage: %s dataset table_name YYYY-MM-DD ending_date\n" $0
    printf "\t%s\tThe dataset for the table\n" 'dataset'
    printf "\t%s\tThe name of the table\n" 'table_name'
    printf "\t%s\tThe partition to be truncated\n" 'YYYY-MM-DD'
    printf "\t%s\tThe last partition to be truncated. If provided, YYYY-MM-DD will be the first, both defined a range\n" 'ending_date'
}

if [[ $# -lt 3 ]]; then
  usage
  exit 1
fi

dataset=${1}
table=${2}
d1=$(date -d "$3" +%s)
if [ $# -gt 3 ]; then
    d2=$(date -d "$4" +%s)
else
    d2=$d1
fi

diff=$(( (d1 - d2) / 86400 * -1))
if [ "$diff" -lt 0 ];then
    echo "Invalid date range: you should provide a starting date that happens before ending date"
    exit
fi

now=$(date -d "now" +%s)
d1=$(( (d1 - now) / 86400 * -1))
d2=$(( (d2 - now) / 86400 * -1))

for i in `seq $d1 -1 $d2`; do date -d "$i days ago" +%Y-%m-%d ; done | uniq > dates.txt
while read line; do
    IFS='-' read -r -a theDate <<< ${line}
    YYYY=${theDate[0]}
    MM=${theDate[1]}
    DD=${theDate[2]}
    YYYYMMDD="$YYYY$MM$DD"
    printf "Truncating $dataset.$table for partition $YYYYMMDD in proyect ${DEVSHELL_PROJECT_ID}\n"

    bq query --replace --noflatten_results --allow_large_results --noflatten_results --allow_large_results --destination_table=$dataset.$table\$$YYYYMMDD "SELECT * FROM [${DEVSHELL_PROJECT_ID}:$dataset.$table] WHERE _PARTITIONTIME=DATE_ADD(CURRENT_DATE(),1,'DAY')"
    exitCode=$?

    if [[ $exitCode -eq 0 ]]; then
        curl --silent "http://bvi-3000.appspot.com/bq_api?op=update&target=$dataset.$table&dateref=$YYYY-$MM-$DD" | sed -e 's/<[^>]*>//g'
        echo ''
    fi
done<dates.txt

rm dates.txt