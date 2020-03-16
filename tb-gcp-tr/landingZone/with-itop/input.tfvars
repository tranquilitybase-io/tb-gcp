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
shared_secrets_project_name   = "shared-secrets"
shared_telemetry_project_name  = "shared-telemetry"
shared_itsm_project_name = "shared-itsm"
shared_billing_project_name    = "shared-billing"
tb_bastion_project_name = "tb-bastion"

#APIs ACTIVATION

service_projects_number = "3"

#SHARED VPC
shared_vpc_name = "shared-network"
standard_network_subnets = [{
  name = "shared-network-snet"
cidr = "10.0.0.0/24" }]
enable_flow_logs = "false"
gke_network_subnets = [{ name = "shared-ec-snet", cidr = "10.0.1.0/24", pod_cidr = "10.1.0.0/17", service_cidr = "10.1.128.0/20" },
  { name = "shared-itsm-snet", cidr = "10.0.2.0/24", pod_cidr = "10.2.0.0/17", service_cidr = "10.2.128.0/20" },
  { name = "shared-secrets-snet", cidr = "10.0.3.0/24", pod_cidr = "10.3.0.0/17", service_cidr = "10.3.128.0/20" },
  { name = "activator-project-snet", cidr = "10.0.4.0/24", pod_cidr = "10.4.0.0/17", service_cidr = "10.4.128.0/20" },
{ name = "workspace-project-snet", cidr = "10.0.5.0/24", pod_cidr = "10.5.0.0/17", service_cidr = "10.5.128.0/20" }]
gke_pod_network_name     = "gke-pods-snet"
gke_service_network_name = "gke-services-snet"

#KUBERNETES SSP CLUSTER
cluster_ec_subnetwork           = "shared-ec-snet"
cluster_ec_service_account      = "kubernetes-ec"
cluster_ec_name                 = "gke-ec"
cluster_ec_pool_name            = "gke-ec-node-pool"
cluster_ec_enable_private_nodes = "true"
cluster_ec_master_cidr          = "172.16.0.0/28"
cluster_ec_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]
#cluster_ec_min_master_version = "latest"
istio_status        = "false"
ec_repository_name = "SSP-activator-tf"

#KUBERNETES SECRETS CLUSTER
cluster_sec_subnetwork           = "shared-secrets-snet"
cluster_sec_service_account      = "kubernetes-sec"
cluster_sec_name                 = "gke-sec"
cluster_sec_pool_name            = "gke-sec-node-pool"
cluster_sec_enable_private_nodes = "true"
cluster_sec_master_cidr          = "172.16.0.16/28"
cluster_sec_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]
#cluster_sec_min_master_version = "latest"
vault-lb-name     = "sec-vault-lb"
sec-vault-keyring = "vault"
location          = "EU"

#KUBERNETES OPERATIONS CLUSTER
cluster_opt_subnetwork           = "shared-itsm-snet"
cluster_opt_service_account      = "kubernetes-opt"
cluster_opt_name                 = "gke-opt"
cluster_opt_pool_name            = "gke-opt-node-pool"
cluster_opt_enable_private_nodes = "true"
cluster_opt_master_cidr          = "172.16.0.32/28"
cluster_opt_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]
#cluster_opt_min_master_version = "latest"

#SSP Deployment
application_yaml_path = "../deployment.yaml"
ec_ui_source_bucket  = "tranquility-base-ui"
ec_iam_service_account_roles = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.projectCreator",
  "roles/compute.xpnAdmin", "roles/resourcemanager.projectDeleter", "roles/billing.projectManager", "roles/owner",
"roles/compute.networkAdmin", "roles/datastore.owner", "roles/browser", "roles/resourcemanager.projectIamAdmin"]

# Vault deployment
sec-vault-crypto-key-name = "vault-init"
sec-lb-name               = "vault-lb"
cert-common-name          = "tb.vault-ca.local"
tls-organization          = "TB Vault"
