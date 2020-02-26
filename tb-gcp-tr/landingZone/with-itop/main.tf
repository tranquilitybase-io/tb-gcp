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

###
# Root module (activates other modules)
###

provider "google" {
  region = var.region
  zone   = var.region_zone
  version = "~> 2.5"
}

provider "google" {
  alias  = "vault"
  region = var.region
  zone   = var.region_zone
  version = "~> 2.5"
}

provider "google-beta" {
  alias   = "shared-vpc"
  region  = var.region
  zone    = var.region_zone
  project = module.shared_projects.shared_networking_id
  version = "~> 2.5"
}

provider "kubernetes" {
  alias = "k8s"
  version = "~> 1.10.0"
}

terraform {
  backend "gcs" {
    # The bucket name below is overloaded at every run with
    # `-backend-config="bucket=${terraform_state_bucket_name}"` parameter
    # templated into the `bootstrap.sh` script 
    bucket = "terraformdevstate"
  }
}

module "folder_structure" {
  source = "../../folder-structure-creation"

  region           = var.region
  region_zone      = var.region_zone
  root_id          = var.root_id
  root_is_org      = var.root_is_org
  tb_discriminator = var.tb_discriminator
}

module "shared_projects" {
  source = "../../shared-projects-creation"

  root_id                        = module.folder_structure.shared_services_id
  billing_account_id             = var.billing_account_id
  shared_networking_project_name = var.shared_networking_project_name
  shared_security_project_name   = var.shared_security_project_name
  shared_telemetry_project_name  = var.shared_telemetry_project_name
  shared_operations_project_name = var.shared_operations_project_name
  shared_billing_project_name    = var.shared_billing_project_name
  tb_bastion_project_name = var.tb_bastion_project_name
}

module "apis_activation" {
  source = "../../apis-activation"

  ssp_project_id          = module.shared_projects.shared_ssp_id
  bastion_project_id              = module.shared_projects.tb_bastion_id
  host_project_id         = module.shared_projects.shared_networking_id
  service_projects_number = var.service_projects_number
  service_project_ids     = [module.shared_projects.shared_security_id, module.shared_projects.shared_operations_id, module.shared_projects.shared_ssp_id]
}

module "shared-vpc" {
  source = "../../shared-vpc"

  host_project_id          = module.shared_projects.shared_networking_id
  shared_vpc_name          = var.shared_vpc_name
  standard_network_subnets = var.standard_network_subnets
  enable_flow_logs         = var.enable_flow_logs
  tags                     = var.tags
  gke_network_subnets      = var.gke_network_subnets
  gke_pod_network_name     = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name
  router_name              = var.router_name
  create_nat_gateway       = var.create_nat_gateway
  router_nat_name          = var.router_nat_name
  service_projects_number  = var.service_projects_number
  service_project_ids      = [module.shared_projects.shared_security_id, module.shared_projects.shared_operations_id, module.shared_projects.shared_ssp_id]
}

module "gke-ssp" {
  source = "../../kubernetes-cluster-creation"

  providers = {
    google                 = google
    google-beta.shared-vpc = google-beta.shared-vpc
  }

  region               = var.region
  sharedvpc_project_id = module.shared_projects.shared_networking_id
  sharedvpc_network    = var.shared_vpc_name

  cluster_enable_private_nodes = var.cluster_ssp_enable_private_nodes
  cluster_project_id           = module.shared_projects.shared_ssp_id
  cluster_subnetwork           = var.cluster_ssp_subnetwork
  cluster_service_account      = var.cluster_ssp_service_account
  cluster_name                 = var.cluster_ssp_name
  cluster_pool_name            = var.cluster_ssp_pool_name
  cluster_master_cidr          = var.cluster_ssp_master_cidr
  cluster_master_authorized_cidrs = concat(
  var.cluster_ssp_master_authorized_cidrs,
  [
    merge(
    {
      "display_name" = "initial-admin-ip"
    },
    {
      "cidr_block" = join("", [var.clusters_master_whitelist_ip, "/32"])
    },
    ),
  ],
  )
  cluster_min_master_version = var.cluster_ssp_min_master_version

  apis_dependency          = module.apis_activation.all_apis_enabled
  shared_vpc_dependency    = module.shared-vpc.gke_subnetwork_ids
  istio_status             = var.istio_status
  gke_pod_network_name     = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name
}

resource "google_sourcerepo_repository" "SSP" {
  name       = var.ssp_repository_name
  project    = module.shared_projects.shared_ssp_id
  depends_on = [module.apis_activation]
}

module "gke-security" {
  source = "../../kubernetes-cluster-creation"

  providers = {
    google                 = google.vault
    google-beta.shared-vpc = google-beta.shared-vpc
  }

  region               = var.region
  sharedvpc_project_id = module.shared_projects.shared_networking_id
  sharedvpc_network    = var.shared_vpc_name

  cluster_enable_private_nodes  = var.cluster_sec_enable_private_nodes
  cluster_project_id            = module.shared_projects.shared_security_id
  cluster_subnetwork            = var.cluster_sec_subnetwork
  cluster_service_account       = var.cluster_sec_service_account
  cluster_service_account_roles = var.cluster_sec_service_account_roles
  cluster_name                  = var.cluster_sec_name
  cluster_pool_name             = var.cluster_sec_pool_name
  cluster_master_cidr           = var.cluster_sec_master_cidr
  cluster_master_authorized_cidrs = concat(
  var.cluster_sec_master_authorized_cidrs,
  [
    merge(
    {
      "display_name" = "initial-admin-ip"
    },
    {
      "cidr_block" = join("", [var.clusters_master_whitelist_ip, "/32"])
    },
    ),
  ],
  )
  cluster_min_master_version = var.cluster_sec_min_master_version
  istio_status               = var.istio_status
  cluster_oauth_scopes       = var.cluster_sec_oauth_scope

  apis_dependency          = module.apis_activation.all_apis_enabled
  shared_vpc_dependency    = module.shared-vpc.gke_subnetwork_ids
  gke_pod_network_name     = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name
}

module "vault" {
  source = "../../vault"

  vault_cluster_project             = module.shared_projects.shared_security_id
  vault-gcs-location                = var.location
  vault-region                      = var.region
  vault_keyring_name                = var.sec-vault-keyring
  vault_crypto_key_name             = var.sec-vault-crypto-key-name
  vault-lb                          = var.sec-lb-name
  vault-sa                          = module.gke-security.cluster_sa
  vault-gke-sec-endpoint            = module.gke-security.cluster_endpoint
  vault-gke-sec-master-auth-ca-cert = module.gke-security.cluster_endpoint
  vault-gke-sec-username            = module.gke-security.cluster_master_auth_username
  vault-gke-sec-password            = module.gke-security.cluster_master_auth_password
  vault-gke-sec-client-ca           = module.gke-security.cluster_master_auth_0_client_certificate
  vault-gke-sec-client-key          = module.gke-security.cluster_master_auth_0_client_key
  vault-gke-sec-cluster_ca_cert     = module.gke-security.cluster_master_auth_0_cluster_ca_certificate
  vault-gke-sec-name                = var.cluster_sec_name

  vault-cert-common-name  = var.cert-common-name
  vault-cert-organization = var.tls-organization

  apis_dependency = module.apis_activation.all_apis_enabled
  #  shared_vpc_dependency = "${module.shared-vpc.gke_subnetwork_ids}"
}

module "gke-operations" {
  source = "../../kubernetes-cluster-creation"

  providers = {
    google                 = google
    google-beta.shared-vpc = google-beta.shared-vpc
    kubernetes             = kubernetes.gke-operations
  }

  region               = var.region
  sharedvpc_project_id = module.shared_projects.shared_networking_id
  sharedvpc_network    = var.shared_vpc_name

  cluster_enable_private_nodes = var.cluster_opt_enable_private_nodes
  cluster_project_id           = module.shared_projects.shared_operations_id
  cluster_subnetwork           = var.cluster_opt_subnetwork
  cluster_service_account      = var.cluster_opt_service_account
  cluster_name                 = var.cluster_opt_name
  cluster_pool_name            = var.cluster_opt_pool_name
  cluster_master_cidr          = var.cluster_opt_master_cidr
  cluster_master_authorized_cidrs = concat(
  var.cluster_opt_master_authorized_cidrs,
  [
    merge(
    {
      "display_name" = "initial-admin-ip"
    },
    {
      "cidr_block" = join("", [var.clusters_master_whitelist_ip, "/32"])
    },
    ),
  ],
  )
  cluster_min_master_version = var.cluster_opt_min_master_version

  apis_dependency          = module.apis_activation.all_apis_enabled
  istio_status             = var.istio_status
  istio_permissive_mtls    = "true"
  shared_vpc_dependency    = module.shared-vpc.gke_subnetwork_ids
  gke_pod_network_name     = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name
}

# Kubernetes provider for the gke-operations cluster
provider "kubernetes" {
  alias                  = "gke-operations"
  host                   = "https://${module.gke-operations.cluster_endpoint}"
  load_config_file       = false
  cluster_ca_certificate = base64decode(module.gke-operations.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
  version = "~> 1.10.0"
}

# Deploy gke-operations cluster helm pre-requisite resources
module "gke_operations_helm_pre_req" {
  source = "../../helm-pre-requisites"
  providers = {
    kubernetes = kubernetes.gke-operations
  }
}

# Set GKE Operations cluster Helm provider
provider "helm" {
  alias = "gke-operations"
  kubernetes {
    host                   = "https://${module.gke-operations.cluster_endpoint}"
    load_config_file       = false
    cluster_ca_certificate = base64decode(module.gke-operations.cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
  service_account = module.gke_operations_helm_pre_req.tiller_svc_accnt_name
  version = "~> 0.10.4"
}

# Deploys itop on GKE Operations cluster

module "itop" {
  source = "../../itop"
  providers = {
    kubernetes = kubernetes.gke-operations
    helm       = helm.gke-operations
  }

  host_project_id       = module.shared_projects.shared_operations_id
  itop_chart_local_path = "../../itop/helm"
  region                = var.region
  region_zone           = var.region_zone
  database_user_name    = var.itop_database_user_name
  k8_cluster_name       = var.cluster_sec_name

  dependency_vars = module.gke-operations.node_id
}


module "k8s-ssp_context" {
  source = "../../k8s-context"

  cluster_name    = var.cluster_ssp_name
  cluster_project = module.shared_projects.shared_ssp_id
  dependency_var  = module.gke-ssp.node_id
}

resource "null_resource" "kubernetes_service_account_key_secret" {
  triggers = {
    content = module.k8s-ssp_context.k8s-context_id
  }

  provisioner "local-exec" {
    command = "kubectl --context=${module.k8s-ssp_context.context_name} create secret generic ssp-service-account --from-file=${local_file.ssp_service_account_key.filename}"
  }

  provisioner "local-exec" {
    command = "kubectl --context=${module.k8s-ssp_context.context_name} delete secret ssp-service-account"
    when    = destroy
  }
}

module "SharedServices_configuration_file" {
  source = "../../../tb-common-tr/start_service"

  k8s_template_file = local_file.ssp_config_map.filename
  cluster_context   = module.k8s-ssp_context.context_name
  dependency_var    = null_resource.kubernetes_service_account_key_secret.id
}

module "SharedServices_ssp" {
  source = "../../../tb-common-tr/start_service"

  k8s_template_file = var.application_yaml_path
  cluster_context   = module.k8s-ssp_context.context_name
  dependency_var    = module.SharedServices_configuration_file.id
}

module "self-service-app" {
  source = "../../gae-self-service-portal"

  project_id         = module.shared_projects.shared_ssp_id
  source_bucket      = var.ssp_ui_source_bucket
  ssp_gke_dependency = null_resource.get_endpoint.id
  endpoint_file      = var.endpoint_file
}

# This is only temporrary piece of code.
# Creating the endpoint file is a part of istio module in tb-common-tr repository
# null_resource.get_endpoint behind can be removed if this module will be integrated (TBASE-194)
resource "null_resource" "get_endpoint" {
  provisioner "local-exec" {
    command = <<EOF
      echo -n 'http://' > ${var.endpoint_file}
      for i in $(seq -s " " 1 35); do
        sleep $i
        ENDPOINT=$(kubectl --context=${module.k8s-ssp_context.context_name} get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ -n "$ENDPOINT" ]; then
          echo "$ENDPOINT" >> ${var.endpoint_file}
          exit 0
        fi
      done

      echo "Loadbalancer is not reachable after 10,5 minutes"
      exit 1
      EOF
  }

  #   command = "echo -n 'http://' > ${var.endpoint_file} && kubectl --context=${module.k8s-ssp_context.context_name} get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' >> ${var.endpoint_file}"

  depends_on = [module.SharedServices_ssp]
}

resource "google_storage_bucket_object" "backend-endpoint" {
  name          = "assets/endpoint-meta.json"
  bucket        = module.self-service-app.bucket_name
  source        = var.endpoint_file
  cache_control = "no-cache, max-age=0"

  # Added depends_on to ensure that this resource isn't created until upload_to_static_host null_resource in module.self-service-app is ready
  depends_on = [
    module.self-service-app,
    null_resource.get_endpoint,
  ]
}

// add bucket to store terraform ssp activator state
resource "random_id" "activator_bucket_name" {
  byte_length = 4
}

resource "google_storage_bucket_iam_binding" "ssp-terraform-state-storage-admin" {
  bucket = var.terraform_state_bucket_name
  role   = "roles/storage.admin"

  members = [
    local.service_account_name,
  ]
}

resource "google_sourcerepo_repository" "activator-terraform-code-store" {
  name       = "terraform-code-store"
  project    = module.shared_projects.shared_ssp_id
  depends_on = [module.apis_activation]
}

resource "google_sourcerepo_repository_iam_binding" "terraform-code-store-admin-binding" {
  repository = google_sourcerepo_repository.activator-terraform-code-store.name
  project    = module.shared_projects.shared_ssp_id
  role       = "roles/source.admin"

  members = [
    local.service_account_name,
  ]
  depends_on = [google_sourcerepo_repository.activator-terraform-code-store]
}

// used only to enable datastore
resource "google_app_engine_application" "enable-datastore" {
  project     = module.shared_projects.shared_ssp_id
  location_id = var.region
  depends_on  = [google_sourcerepo_repository_iam_binding.terraform-code-store-admin-binding]
}

module "bastion-security" {
  source = "../../bastion"

  tb_bastion_id = module.shared_projects.tb_bastion_id
  shared_networking_id = module.shared_projects.shared_networking_id
  nat_static_ip = module.shared-vpc.nat_static_ip
}

