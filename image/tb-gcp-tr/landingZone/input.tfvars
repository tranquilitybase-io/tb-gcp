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

#FOLDER STRUCTURE CREATION
region = "europe-west2"
region_zone = "europe-west2-a"
root_id = "943956663445"
root_is_org = "false"

#SHARED PROJECTS CREATION
billing_account_id = "01A2F5-73127B-50AE5B"
shared_networking_project_name = "shared-networking"
shared_security_project_name = "shared-security"
shared_telemetry_project_name = "shared-telemetry"
shared_operations_project_name = "shared-operations"
shared_billing_project_name = "shared-billing"

#APIs ACTIVATION

service_projects_number = "3"

#SHARED VPC
shared_vpc_name = "shared-network"
standard_network_subnets = [{name="shared-network-snet" cidr="10.0.0.0/24"}]
enable_flow_logs = "false"
gke_network_subnets = [{name="shared-ssp-snet" cidr="10.0.1.0/24" pod_cidr="10.1.0.0/17" service_cidr = "10.1.128.0/20" },
  {name="shared-operations-snet" cidr="10.0.2.0/24" pod_cidr="10.2.0.0/17" service_cidr = "10.2.128.0/20"},
  {name="shared-security-snet" cidr="10.0.3.0/24" pod_cidr="10.3.0.0/17" service_cidr = "10.3.128.0/20"},
  {name="activator-project-snet" cidr="10.0.4.0/24" pod_cidr="10.4.0.0/17" service_cidr = "10.4.128.0/20"},
  {name="workspace-project-snet" cidr="10.0.5.0/24" pod_cidr="10.5.0.0/17" service_cidr = "10.5.128.0/20"}]
gke_pod_network_name = "gke-pods-snet"
gke_service_network_name = "gke-services-snet"

#KUBERNETES SSP CLUSTER
cluster_ssp_subnetwork = "shared-ssp-snet"
cluster_ssp_service_account = "kubernetes-ssp"
cluster_ssp_name = "gke-ssp"
cluster_ssp_pool_name = "gke-ssp-node-pool"
cluster_ssp_master_cidr="172.16.0.0/28"
cluster_ssp_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]
cluster_ssp_min_master_version = "1.12.8"
istio_status = "false"
ssp_repository_name = "SSP-activator-tf"

#KUBERNETES SECURITY CLUSTER
cluster_sec_subnetwork = "shared-security-snet"
cluster_sec_service_account = "kubernetes-sec"
cluster_sec_name = "gke-sec"
cluster_sec_pool_name = "gke-sec-node-pool"
cluster_sec_master_cidr="172.16.0.16/28"
cluster_sec_master_authorized_cidrs = [
  {
    cidr_block   = "0.0.0.0/0"
    display_name = "mgmt-1"
  }
]
cluster_sec_min_master_version = "1.12.8"
vault-lb-name = "sec-vault-lb"
sec-vault-keyring = "vault"
location = "EU"

#KUBERNETES OPERATIONS CLUSTER
cluster_opt_subnetwork = "shared-operations-snet"
cluster_opt_service_account = "kubernetes-opt"
cluster_opt_name = "gke-opt"
cluster_opt_pool_name = "gke-opt-node-pool"
cluster_opt_master_cidr="172.16.0.32/28"
cluster_opt_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]
cluster_opt_min_master_version = "1.12.8"

#SSP Deployment
application_yaml_path = "./deployment.yaml"

ssp_iam_service_account_roles = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.projectCreator",
  "roles/compute.xpnAdmin", "roles/resourcemanager.projectDeleter", "roles/billing.projectManager", "roles/owner",
  "roles/compute.networkAdmin", "roles/datastore.owner", "roles/browser", "roles/resourcemanager.projectIamAdmin"]

# Vault deployment
vault_keyring_name = "vault"
sec-vault-crypto-key-name = "vault-init"
sec-lb-name = "vault-lb"
cert-common-name = "gft.vault-ca.local"
tls-organization = "GFT Financal Vault"
