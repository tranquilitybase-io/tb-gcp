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
}

provider "google-beta" {
  region = var.region
  zone   = var.region_zone
}

provider "kubernetes" {
  alias = "k8s"
}

provider "tls" {
  version = "~> 2.2"
}

terraform {
  backend "gcs" {
    # The bucket name below is overloaded at every run with
    # `-backend-config="bucket=${terraform_state_bucket_name}"` parameter
    # templated into the `bootstrap.sh` script 
    bucket = "terraformdevstate"

  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.3"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.3"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

module "folder_structure" {
  source = "../../folder-structure-creation"

  region           = var.region
  region_zone      = var.region_zone
  root_id          = var.root_id
  tb_discriminator = var.tb_discriminator
}

module "shared_projects" {
  source = "../../shared-projects-creation"

  tb_discriminator               = var.tb_discriminator
  root_id                        = module.folder_structure.shared_services_id
  billing_account_id             = var.billing_account_id
  shared_networking_project_name = var.shared_networking_project_name
  shared_telemetry_project_name  = var.shared_telemetry_project_name
  shared_itsm_project_name       = var.shared_itsm_project_name
  shared_billing_project_name    = var.shared_billing_project_name
  shared_bastion_project_name    = var.shared_bastion_project_name
  labels                         = var.labels
}

module "gcs_bucket_logging" {
  source = "github.com/tranquilitybase-io/terraform-google-cloud-storage.git//modules/simple_bucket?ref=v1.6.0-logging"

  name        = "${var.gcs_logs_bucket_prefix}-${var.tb_discriminator}"
  project_id  = module.shared_projects.shared_telemetry_id
  iam_members = var.iam_members_bindings
  location    = var.region
}

module "apis_activation" {
  source                   = "../../apis-activation"
  bastion_project_id       = module.shared_projects.shared_bastion_id
  host_project_id          = module.shared_projects.shared_networking_id
  eagle_console_project_id = module.shared_projects.shared_ec_id
}


module "shared-vpc" {
  source = "../../shared-vpc"

  host_project_id          = module.shared_projects.shared_networking_id
  region                   = var.region
  shared_vpc_name          = var.shared_vpc_name
  standard_network_subnets = var.standard_network_subnets
  bastion_subnet_name      = var.bastion_subnetwork_name
  bastion_subnet_cidr      = var.bastion_subnetwork_cidr
  enable_flow_logs         = var.enable_flow_logs
  tags                     = var.tags
  gke_network_subnets      = var.gke_network_subnets
  gke_pod_network_name     = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name
  router_name              = var.router_name
  create_nat_gateway       = var.create_nat_gateway
  router_nat_name          = var.router_nat_name
  service_projects_number  = var.service_projects_number
  service_project_ids      = [module.shared_projects.shared_itsm_id, module.shared_projects.shared_ec_id]
  private_dns_name         = var.private_dns_name
  private_dns_domain_name  = var.private_dns_domain_name
}

##### Audit logging #####

module "audit-log-bucket" {
  source = "github.com/tranquilitybase-io/terraform-google-cloud-storage.git//modules/simple_bucket?ref=logging-v3"

  project_id      = module.shared_projects.shared_telemetry_id
  name            = "${var.tb_folder_admin_rw_audit_log_bucket_name}-${var.tb_discriminator}"
  location        = var.tb_folder_admin_rw_audit_log_bucket_location
  storage_class   = var.tb_folder_admin_rw_audit_log_bucket_storage_class
  labels          = var.tb_folder_admin_rw_audit_log_bucket_labels
  lifecycle_rules = var.tb_folder_admin_rw_audit_log_bucket_lifecycle_rules
}

resource "google_logging_folder_sink" "audit-log-sink" {
  folder           = var.root_id
  name             = var.tb_folder_admin_rw_audit_log_sink_name
  destination      = "storage.googleapis.com/${module.audit-log-bucket.name}"
  filter           = var.tb_folder_admin_rw_audit_log_bucket_filter
  include_children = var.include_children
}

resource "google_storage_bucket_iam_binding" "audit-bucket-iam-binding" {
  bucket  = module.audit-log-bucket.name
  role    = "roles/storage.objectCreator"
  members = [google_logging_folder_sink.audit-log-sink.writer_identity]
}

#####

module "bastion-security" {
  source = "../../shared-bastion"

  bastion_subnetwork_name       = module.shared-vpc.bastion_subnetwork_name
  region                        = var.region
  region_zone                   = var.region_zone
  shared_bastion_id             = module.shared_projects.shared_bastion_id
  shared_networking_id          = module.shared_projects.shared_networking_id
  root_id                       = var.root_id
  shared_bastion_project_number = module.shared_projects.shared_bastion_project_number
  depends_on = [module.shared-vpc]
}

module "dns-instances" {
  source = "../../dns-instances"

  linux_instances = module.bastion-security.linux_bastion_instances
  private_dns_domain_name = module.shared-vpc.dns_domain_name
  private_dns_name = module.shared-vpc.dns_name
  squid_proxy_instances = module.bastion-security.squid_proxy_instances
  windows_instances = module.bastion-security.windows_bastion_instances
  zone = var.region_zone
  depends_on = [module.bastion-security]
}

module "logging_export" {
  source                        = "../../logging-export"
  tb_discriminator              = var.tb_discriminator
  shared_telemetry_project_name = module.shared_projects.shared_telemetry_id
  shared_services_id            = module.folder_structure.shared_services_id
  applications_id               = module.folder_structure.activators_id
  location                      = var.region
}

module "gke-ec" {
  source = "../../kubernetes-cluster-creation"

  region               = var.region
  sharedvpc_project_id = module.shared_projects.shared_networking_id
  sharedvpc_network    = var.shared_vpc_name

  cluster_enable_private_nodes    = var.cluster_ec_enable_private_nodes
  cluster_enable_private_endpoint = var.cluster_ec_enable_private_endpoint
  cluster_project_id              = module.shared_projects.shared_ec_id
  cluster_subnetwork              = var.cluster_ec_subnetwork
  cluster_service_account         = var.cluster_ec_service_account
  cluster_name                    = var.cluster_ec_name
  cluster_pool_name               = var.cluster_ec_pool_name
  cluster_master_cidr             = var.cluster_ec_master_cidr
  cluster_master_authorized_cidrs = concat(
    var.cluster_ec_master_authorized_cidrs,
    [
      merge(
        {
          "display_name" = "initial-admin-ip"
        },
        {
          "cidr_block" = "172.16.0.18/32"
        },
      ),
    ],
  )
  cluster_min_master_version        = var.cluster_ec_min_master_version
  cluster_default_max_pods_per_node = var.cluster_ec_default_max_pods_per_node

  apis_dependency          = module.apis_activation.all_apis_enabled
  shared_vpc_dependency    = module.shared-vpc.gke_subnetwork_ids
  shared_ec_dependency     = module.shared_projects.shared_ec_id
  istio_status             = var.istio_status
  gke_pod_network_name     = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name

  depends_on = [
    module.shared_projects.shared_networking_id,
    module.shared_projects.shared_ec_id
  ]

}

resource "google_sourcerepo_repository" "EC" {
  name       = var.ec_repository_name
  project    = module.shared_projects.shared_ec_id
  depends_on = [module.apis_activation]
}

module "k8s-ec_context" {
  source = "../../k8s-context"

  cluster_name    = var.cluster_ec_name
  region          = var.region
  cluster_project = module.shared_projects.shared_ec_id
  dependency_var  = module.gke-ec.node_id
}

module "tls" {
  source = "../../tls"
}
## Creating the ssp and cicd namespaces in the shared services cluster ## depends on the k8-ec_content module 
module "SharedServices_namespace_creation" {
  source = "../../../tb-common-tr/start_service"

  k8s_template_file = var.sharedservice_namespace_yaml_path
  cluster_context   = module.k8s-ec_context.context_name
  dependency_var    = module.k8s-ec_context.k8s-context_id
}

## Creates service account for eagle console in the ssp namespace ##

resource "null_resource" "kubernetes_service_account_key_secret" {
  triggers = {
    content = module.SharedServices_namespace_creation.id
    k8_name = module.k8s-ec_context.context_name
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${module.k8s-ec_context.context_name} create secret generic ec-service-account -n ssp --from-file=${local_file.ec_service_account_key.filename}' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${self.triggers.k8_name} delete secret ec-service-account' -n ssp | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
    when    = destroy
  }
}

### Jenkins service account file ######

resource "null_resource" "kubernetes_jenkins_service_account_key_secret" {
  triggers = {
    content = module.SharedServices_namespace_creation.id
    k8_name = module.k8s-ec_context.context_name
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${module.k8s-ec_context.context_name} create secret generic ec-service-account -n cicd --from-file=${local_file.ec_service_account_key.filename}' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
  }

  provisioner "local-exec" {
    command = "echo 'kubectl --context=${self.triggers.k8_name} delete secret ec-service-account' -n cicd | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh"
    when    = destroy
  }
}

### Jenkins Deployment Depends on the ec-service-account secret creation####

module "SharedServices_jenkinsmaster_creation" {
  source = "../../../tb-common-tr/start_service"

  k8s_template_file = var.sharedservice_jenkinsmaster_yaml_path
  cluster_context   = module.k8s-ec_context.context_name
  dependency_var    = null_resource.kubernetes_jenkins_service_account_key_secret.id
}

module "SharedServices_configuration_file" {
  source = "../../../tb-common-tr/start_service"

  k8s_template_file = local_file.ec_config_map.filename
  cluster_context   = module.k8s-ec_context.context_name
  dependency_var    = null_resource.kubernetes_service_account_key_secret.id
}

module "SharedServices_ec" {
  source = "../../../tb-common-tr/start_service"

  k8s_template_file = var.eagle_console_yaml_path
  cluster_context   = module.k8s-ec_context.context_name
  dependency_var    = module.SharedServices_configuration_file.id
}

resource "null_resource" "get_endpoint" {
  provisioner "local-exec" {
    command = <<EOF
      echo 'echo -n 'http://' > ${var.endpoint_file}
      for i in $(seq -s " " 1 35); do
        sleep $i
        ENDPOINT=$(kubectl --context=${module.k8s-ec_context.context_name} get svc istio-private-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ -n "$ENDPOINT" ]; then
          echo "$ENDPOINT" >> ${var.endpoint_file}
          exit 0
        fi
      done
      echo "Loadbalancer is not reachable after 10,5 minutes"
      exit 1' | tee -a /opt/tb/repo/tb-gcp-tr/landingZone/kube.sh
      EOF
  }

  #   command = "echo -n 'http://' > ${var.endpoint_file} && kubectl --context=${module.k8s-ec_context.context_name} get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' >> ${var.endpoint_file}"

  depends_on = [module.SharedServices_ec]
}

resource "google_sourcerepo_repository" "activator-terraform-code-store" {
  name       = "terraform-code-store"
  project    = module.shared_projects.shared_ec_id
  depends_on = [module.apis_activation]
}

resource "google_sourcerepo_repository_iam_binding" "terraform-code-store-admin-binding" {
  repository = google_sourcerepo_repository.activator-terraform-code-store.name
  project    = module.shared_projects.shared_ec_id
  role       = "roles/source.admin"

  members = [
    local.service_account_name,
  ]
  depends_on = [google_sourcerepo_repository.activator-terraform-code-store]
}
