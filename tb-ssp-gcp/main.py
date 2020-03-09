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

import yaml, re
from flask import Flask, request
from flask_cors import CORS

from python_terraform import *
from modules import add_to_log
from modules import commit_terraform
from modules import subnet_pool_handler
from modules import gcloud
from modules.local_logging import get_logger

logger = get_logger()
logger.info("Logger initialised")

app = Flask(__name__)
app.logger = logger  # use our own logger for consistency vs flasks own
CORS(app)


@app.route("/isalive", endpoint='isalive', methods=['GET'])
def is_alive():
    """
    Helper function to determine if the API is active or not.

    :return: HTTP response for Flask to render
    """
    config = read_config_map()
    for k, v in config.items():
        print(k, v)

    response = app.make_response("Backend is working!")
    response.headers['Access-Control-Allow-Origin'] = '*'

    return response


@app.route("/destroy", endpoint='destroy', methods=['POST'])
@app.route("/build", endpoint='build', methods=['POST'])
def run_terraform():
    """
    Builds and destroys infrastructure using an activator, responding POST requests to /build and /destroy endpoints.

    The configuration YAML file read by read_config_map() determines where this new infrastructure should sit
    within a GCP project, as well as setting other properties like billing.

    Accepts JSON content-type input.

    :return: HTTP response to be rendered by Flask
    """
    postdata = request.json
    tf_data = postdata.get("tf_data")
    app_name = postdata.get("app_name", 'default_activator')

    config = read_config_map()

    tf_data['region'] = config['region']
    tf_data['activator_folder_id'] = config['activator_folder_id']
    tf_data['billing_account'] = config['billing_account']
    tf_data['shared_vpc_host_project'] = config['shared_vpc_host_project']
    app_lower = app_name.lower()
    tf_data['app_name'] = app_lower
    backend_prefix = re.sub('[^0-9a-zA-Z]+', '-', app_lower)
    env_data = config['env_data']

    add_to_log.add_to_log(postdata.get("user"), app_name, tf_data, config)

    terraform_source_path = '/opt/tb/repo/tb-gcp-activator/'  # this should be the param to python script
    activator_terraform_code_store = config['activator_terraform_code_store']
    gcloud.clone_code_store(config['ssp_project_name'], activator_terraform_code_store)

    update_activator_input_subnets(backend_prefix, config, terraform_source_path, backend_prefix)

    tf = Terraform(working_dir=terraform_source_path, variables=tf_data)
    return_code, stdout, stderr = tf.init(capture_output=False,
                                          backend_config={'bucket': config['terraform_state_bucket'],
                                                          'prefix': backend_prefix})

    if request.endpoint.lower() == 'destroy'.lower():
        return_code, stdout, stderr = tf.destroy(var_file=env_data, capture_output=False)
    else:
        return_code, stdout, stderr = tf.apply(skip_plan=True, var_file=env_data, capture_output=False)

    commit_terraform.commit_terraform(terraform_source_path, backend_prefix, postdata.get("user"),
                                      activator_terraform_code_store)

    response = app.make_response("done")
    response.headers['Access-Control-Allow-Origin'] = '*'

    return response


def update_activator_input_subnets(backend_prefix, config, terraform_activator_path, formatted_app_name):
    """
    Creates subnets for an existing activator

    :param backend_prefix: prefix string for the subnets
    :param config: dictionary-based config
    :param terraform_activator_path: path on disk to the activator. should contain an input.tfvars file.
    :param formatted_app_name: application name
    :return:
    """
    terraform_subnets_path = '/opt/ssp/tf_create_subnets/'
    allocated_subnet_cirds = subnet_pool_handler.retrieve_free_subnet_cidrs('10.0.11.0/24', '10.0.255.0/24', config,
                                                                            formatted_app_name)

    subnet_pool_handler.update_tf_subnets_input_tfvars(allocated_subnet_cirds, terraform_subnets_path + 'input.tfvars')
    allocated_subnet_names = subnet_pool_handler.tf_create_subnets(backend_prefix, config, request,
                                                                   terraform_subnets_path)
    subnet_pool_handler.update_tf_activator_input_tfvars(terraform_activator_path, allocated_subnet_names)
    print('Activator subnets update finished')


def read_config_map():
    """
    Returns the SSP configuration as a dictionary

    :return: dict of config
    """
    try:
        with open("/app/ssp-config.yaml", 'r') as stream:
            try:
                return yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                logger.exception("Failed to parse SSP YAML after successfully opening")
                raise
    except Exception:
        logger.exception("Failed to load SSP YAML file")
        raise


if __name__ == "__main__":
    app.run(host='0.0.0.0', threaded=True)
