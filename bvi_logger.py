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
# This file implements the log format to be used by the Error Logging dashboard queries

import logging


def bvi_log(date, resource="Main", message_id="ERROR", message="Error", regenerate=False):
    logging.info(
        "BVI LOG ::: DATE=%s ::: RESOURCE=%s ::: MESSAGE_ID=%s ::: MESSAGE=%s ::: REGENERATE=%s",
        date, resource, message_id, message, regenerate)
