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

resource "local_file" "ec_config_map" {
  content  = local.ec_config_map_configuration
  filename = "/tmp/tb-gcp-tr/bootstrap/ec-config.yaml"
}

locals {
  ec_config_map_configuration = <<FILE
apiVersion: v1
kind: ConfigMap
metadata:
  name: ec-config
  namespace: default
data:
  ec-config.yaml: |
    activator_folder_id: ${module.folder_structure.activators_id}
    billing_account: ${var.billing_account_id}
    region: ${var.region}
    terraform_state_bucket: ${var.terraform_state_bucket_name}
    env_data: input.tfvars
    ec_project_name: ${module.shared_projects.shared_ec_name}
    shared_vpc_host_project: ${module.shared_projects.shared_networking_id}
    shared_network_name: ${var.shared_vpc_name}
    shared_networking_id: ${module.shared_projects.shared_networking_id}
FILE

}

