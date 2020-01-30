# Copyright 2017 Google Inc. All rights reserved.
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
"""Enables APIs on a specified project."""


def GenerateConfig(context):
  """Generates config."""

  projectNumber = context.env['project_number']
  billingAccountId = context.properties['billingAccountId']
  concurrent_api_activation= context.properties['concurrentApiActivation']

  resources = []
  for index, api in enumerate(context.properties['apis']):
    depends_on = [projectNumber, billingAccountId]
    # Serialize the activation of all the apis by making api_n depend on api_n-1
    if (not concurrent_api_activation) and index != 0:
        depends_on.append(ApiResourceName(projectNumber, context.properties['apis'][index-1]))
    resources.append({
        'name': ApiResourceName(projectNumber, api),
        'type': 'deploymentmanager.v2.virtual.enableService',
        'metadata': {
            'dependsOn': depends_on
        },
        'properties': {
            'consumerId': 'project:' + projectNumber,
            'serviceName': api
        }
    })
  return {'resources': resources}


def ApiResourceName(projectNumber, api_name):
  return projectNumber + '-' + api_name

