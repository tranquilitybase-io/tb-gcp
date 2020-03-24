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

from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
from netaddr import *
from tempfile import mkstemp
from shutil import move
from os import popen
from os import fdopen, remove
from python_terraform import *
import re


def retrieve_free_subnet_cidrs(start_range_str, end_range_str, config, formatted_app_name):
    project = config['shared_networking_id']
    region = config['region']

    credentials = GoogleCredentials.get_application_default()
    service = discovery.build('compute', 'v1', credentials=credentials)
    start_range = IPNetwork(start_range_str)
    end_range = IPNetwork(end_range_str)
    reserved_cirds = []

    existing_subnets = ['activator-' + formatted_app_name + '-snet', 'workspace-' + formatted_app_name + '-snet']
    # find all subnets
    already_exist_subnets = {}
    request = service.subnetworks().list(project=project, region=region)
    while request is not None:
        response = request.execute()
        for subnetwork in response['items']:
            if subnetwork['name'] in existing_subnets:
                already_exist_subnets[subnetwork['name']] = subnetwork['ipCidrRange']

            if IPNetwork(subnetwork['ipCidrRange']) >= start_range:
                reserved_cirds.append(IPNetwork(subnetwork['ipCidrRange']))

        request = service.subnetworks().list_next(previous_request=request, previous_response=response)

    if len(already_exist_subnets.keys()) == len(existing_subnets):
        return already_exist_subnets
    if len(already_exist_subnets.keys()) != 0 and len(already_exist_subnets.keys()) != len(existing_subnets):
        raise Exception(
            'One of the subnet already created: ' + str(already_exist_subnets.keys()) + ' . Please remove it first')

    return find_free_subnets_cidrs(end_range, reserved_cirds, start_range, existing_subnets)


def find_free_subnets_cidrs(end_range, reserved_cirds, start_range, subnet_names):
    allowed_range = {}
    subnet_name = iter(subnet_names)
    while start_range <= end_range:
        if start_range not in reserved_cirds:
            allowed_range[next(subnet_name)] = str(start_range)
        if len(allowed_range.keys()) >= len(subnet_names):
            break
        start_range = start_range.next()
    return allowed_range


def update_tf_subnets_input_tfvars(allocated_subnets, input_tfvars_path):
    subnet_cidrs_tf_variable = "free_subnet_cidrs"
    subnet_name_tf_variable = "subnets-name"
    remove_variable(subnet_cidrs_tf_variable, input_tfvars_path)
    remove_variable(subnet_name_tf_variable, input_tfvars_path)
    write_cidr_variable(str(list(allocated_subnets.values())), subnet_cidrs_tf_variable, input_tfvars_path)
    write_cidr_variable(str(list(allocated_subnets.keys())), subnet_name_tf_variable, input_tfvars_path)


def write_cidr_variable(alocated_subnets, subnet_cidrs, tf_input_path):
    f = open(tf_input_path, "a+")
    f.write(subnet_cidrs + " = " + str(alocated_subnets).replace("'", "\"") + "\n")
    f.close()


def remove_variable(subnet_cidrs, tf_input_path):
    with open(tf_input_path, "r") as f:
        lines = f.readlines()
    with open(tf_input_path, "w") as f:
        for line in lines:
            if subnet_cidrs not in line:
                f.write(line)


def update_tf_activator_input_tfvars(terraform_activator_path, allocated_subnet_names):
    tf_input_path = os.path.join(terraform_activator_path, 'input.tfvars')
    subnet_variables = ['activator_cluster_subnetwork', 'workspace_cluster_subnetwork']
    if len(allocated_subnet_names) != len(subnet_variables):
        raise Exception('Number of subnets must match with number of variables')
    i = 0
    while i < len(subnet_variables):
        replace(tf_input_path, subnet_variables[i],
                subnet_variables[i] + " = " + "\"" + allocated_subnet_names[i] + "\"")
        i += 1


def replace(file_path, pattern, subst):
    fh, temp_file = mkstemp()
    with fdopen(fh, 'w+') as new_file:
        with open(file_path) as old_file:
            for line in old_file:
                if re.match(pattern, line):
                    new_file.write(subst + "\n")
                else:
                    new_file.write(line)
    remove(file_path)
    move(temp_file, file_path)


# Use a terraform to create subnets
def tf_create_subnets(backend_prefix, config, request, terraform_subnets_path):
    popen("rm -rf " + terraform_subnets_path + ".terraform")
    popen("rm -rf " + terraform_subnets_path + "subnet_names")
    print("backend_prefix: " + backend_prefix)
    tf_subnets_data = {
        "shared_network_name": config['shared_network_name'],
        "shared_networking_id": config['shared_networking_id']
    }

    tf_subnets = Terraform(working_dir=terraform_subnets_path, variables=tf_subnets_data)
    env_data_subnets = 'input.tfvars'
    return_code, stdout, stderr = tf_subnets.init(capture_output=False,
                                                  backend_config={'bucket': config['terraform_state_bucket'],
                                                                  'prefix': backend_prefix + '_subnets'})
    if request.endpoint.lower() == 'build'.lower():
        return_code, stdout, stderr = tf_subnets.apply(skip_plan=True, var_file=env_data_subnets, capture_output=False)

    with open(terraform_subnets_path + 'subnet_names') as cirds:
        allocated_subnet_names = str(cirds.readline()).split(",")

    return allocated_subnet_names
