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

import datetime
from google.cloud import datastore
from modules.local_logging import get_logger


logger = get_logger()


def create_client(project_id):
    """
    Returns a datastore client object for a given project

    :param project_id:
    :return: datastore.Client
    """

    return datastore.Client(project_id)


def list_logs(client):
    """
    Lists the terraform event logs for a given project.

    :param client: a datastore client
    :return: list of datastore entries
    """

    query = client.query(kind='TerraformEventLog')
    return list(query.fetch())


def add_gcp_log(user, app_name, app_id, tf_data, env_data, ec_project_name):
    """
    Logs an activity to the datastore terraform event logs. Useful for auditing.

    All logs are timestamped.

    :param user: user who performed the action
    :param app_name: application name to log
    :param app_id: application id to log
    :param tf_data: terraform data to log
    :param env_data: environment data to log
    :param ec_project_name: project name of the EC project, where these logs are saved to
    :return: None
    """

    client = datastore.Client(project=ec_project_name)

    with client.transaction():
        key = client.key('TerraformEventLog')

        task = datastore.Entity(key, exclude_from_indexes=('description',))
        # extra comma is to ensure param is a tuple, as datastore.Entity expects
        # otherwise ('description') would be typed as a string.

        task.update({
            'created': datetime.datetime.utcnow(),
            'user': user,
            'app_name': app_name,
            'app_id': app_id,
            'tf_data': tf_data,
            'env_data': env_data
        })

    client.put(task)
    logger.info("Added to GCP log")

