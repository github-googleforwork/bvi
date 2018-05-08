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

# This file helps on the BVI project deployment

if [ ! -f app.yaml ]; then
    echo "app.yaml not found! ... please, run first pre_deploy script"
    exit 1
fi
if [ ! -f config.yaml ]; then
    echo "config.yaml not found! ... please, run first pre_deploy script"
    exit 1
fi

#read configuration!
. parse_yaml.sh
eval "$(parse_yaml app.yaml 'bvicfg_')"

bvicfg_version=${bvicfg_version:=$1}
bvicfg_version=${bvicfg_version:='master'}
if [ ! -z "${bvicfg_version}" ]; then
	echo "Suggested version: ${bvicfg_version}"
	echo "Enter the version identifier and press [ENTER]"
	echo -n "(if you provide nothing, ${bvicfg_version} will be used): "
	read version
	version=${version:=${bvicfg_version}}
	bvicfg_version=${version}
else
	while [ -z "${bvicfg_version}" ] ; do
		echo -n "Enter the version identifier and press [ENTER]: "
		read bvicfg_version
	done
fi
echo "the version ${bvicfg_version} will be deployed"

if [ "${bvicfg_version}" != 'master' ]; then
	promote=''
	while [ "${promote}" != 'Y' ] && [ "${promote}" != 'n' ] ; do
		echo -n "Do you want to promote ${bvicfg_version} to serve all incoming traffic? [Y/n] "
		read promote
	done
	if [ "${promote}" = 'Y' ]; then
		promote='--promote'
	else
		promote='--no-promote'
	fi
else
	promote='--promote'
fi

if [ ! -d lib ]; then
	echo "unzipping libraries..."
	unzip -q lib.zip
	gcloud app deploy --version=${bvicfg_version} ${promote} --verbosity=info app.yaml cron.yaml queue.yaml
	echo "Removing temporary files..."
	rm -rf lib
else
	gcloud app deploy --version=${bvicfg_version} ${promote} --verbosity=info app.yaml cron.yaml queue.yaml
fi

echo "Deployment done"
