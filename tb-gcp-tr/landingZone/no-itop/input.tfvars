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

#SHARED PROJECTS CREATION
shared_networking_project_name = "shared-networking"
shared_telemetry_project_name  = "shared-telemetry"
shared_itsm_project_name       = "shared-itsm"
shared_billing_project_name    = "shared-billing"
shared_bastion_project_name    = "shared-bastion"

#APIs ACTIVATION

service_projects_number = "2"

#SHARED VPC
shared_vpc_name          = "shared-network"
enable_flow_logs         = "false"
gke_pod_network_name     = "gke-pods-snet"
gke_service_network_name = "gke-services-snet"

#CLOUD DNS
private_dns_name        = "private-shared"
private_dns_domain_name = "private.landing-zone.com." # domain requires . to finish

#KUBERNETES EC CLUSTER
cluster_ec_subnetwork              = "shared-ec-snet"
cluster_ec_service_account         = "kubernetes-ec"
cluster_ec_name                    = "gke-ec"
cluster_ec_pool_name               = "gke-ec-node-pool"
cluster_ec_enable_private_nodes    = "true"
cluster_ec_enable_private_endpoint = true

#cluster_ec_min_master_version = "latest"
istio_status       = "true"
ec_repository_name = "EC-activator-tf"

#KUBERNETES OPERATIONS CLUSTER
cluster_opt_subnetwork              = "shared-itsm-snet"
cluster_opt_service_account         = "kubernetes-opt"
cluster_opt_name                    = "gke-opt"
cluster_opt_pool_name               = "gke-opt-node-pool"
cluster_opt_enable_private_nodes    = "true"
cluster_opt_enable_private_endpoint = false

#EC Deployment
eagle_console_yaml_path = "/opt/tb/repo/tb-gcp-tr/shared-dac/eagle_console.yaml"
ec_ui_source_bucket     = "tranquility-base-ui"
ec_iam_service_account_roles = [
  "roles/resourcemanager.folderAdmin",
  "roles/resourcemanager.projectCreator",
  "roles/compute.xpnAdmin",
  "roles/resourcemanager.projectDeleter",
  "roles/billing.projectManager",
  "roles/owner",
  "roles/compute.networkAdmin",
  "roles/datastore.owner",
  "roles/browser",
"roles/resourcemanager.projectIamAdmin"]

#DAC Services
sharedservice_namespace_yaml_path     = "/opt/tb/repo/tb-gcp-tr/shared-dac/namespaces.yaml"
sharedservice_jenkinsmaster_yaml_path = "/opt/tb/repo/tb-gcp-tr/shared-dac/jenkins-master.yaml"