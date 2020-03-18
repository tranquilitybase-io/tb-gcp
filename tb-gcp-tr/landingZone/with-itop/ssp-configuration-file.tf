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

resource "local_file" "ssp_config_map" {
  content  = local.ssp_config_map_configuration
  filename = "/tmp/tb-gcp-tr/bootstrap/ssp-config.yaml"
}

locals {
  ssp_config_map_configuration = <<FILE
apiVersion: v1
kind: ConfigMap
metadata:
  name: ssp-config
  namespace: default
data:
  ssp-config.yaml: |
    activator_folder_id: ${module.folder_structure.activators_id}
    billing_account: ${var.billing_account_id}
    region: ${var.region}
    terraform_state_bucket: ${var.terraform_state_bucket}
    env_data: input.tfvars
    ssp_project_name: ${module.shared_projects.shared_ssp_name}
    activator_terraform_code_store: ${google_sourcerepo_repository.activator-terraform-code-store.name}
    shared_vpc_host_project: ${module.shared_projects.shared_networking_id}
    shared_network_name: ${var.shared_vpc_name}
    shared_networking_id: ${module.shared_projects.shared_networking_id}
FILE

}

