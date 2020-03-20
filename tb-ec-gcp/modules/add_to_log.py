# Copyright 2019 The Tranquility Base Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from modules import datastore
from modules import commit_terraform
from modules.local_logging import get_logger

logger = get_logger()


def add_to_log(user, app_name, tf_data, config):
    env_data = config['env_data']
    ec_project_name = config['ec_project_name']
    app_id = commit_terraform.create_hash(user, app_name)

    try:
        datastore.add_gcp_log(user, app_name, app_id, tf_data, env_data, ec_project_name)
    except Exception as e:  # not an end-of-the-world failure, don't push the exception upstream for now
        logger.exception("Error while saving log to datastore")