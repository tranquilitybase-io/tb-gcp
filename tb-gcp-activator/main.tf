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

provider "google" {
  version = "~> 2.5"
  region = "${var.region}"
}

provider "google-beta" {
  alias   = "shared-vpc"
  region  = "${var.region}"
  zone    = "${var.zone}"
  project = "${var.shared_vpc_host_project}"
  version = "~> 2.5"
  //project = "${google_project.activator.id}"
}

terraform {
  backend "gcs" {
    bucket  = "terraformdevstate"
  }
}

resource "random_id" "project" {
  byte_length = 14
}

locals {
  # Activator project name is pasted from activator prefix, app name and random_id.
  # It must be 6 to 30 with lowercase letters, digits, hyphens and start with a letter. Trailing hyphens are prohibited.
  activator_name_id = "${substr("${var.activator_project_name}-${var.app_name}-${random_id.project.hex}", 0, 30)}"
  activator_project_name = "${replace("${replace(local.activator_name_id, "/[^0-9a-zA-Z-]+/", "-")}", "/-$/", "")}"
  workspace_name_id = "${substr("${var.workspace_project_name}-${var.app_name}-${random_id.project.hex}", 0, 30)}"
  workspace_project_name = "${replace("${replace(local.workspace_name_id, "/[^0-9a-zA-Z-]+/", "-")}", "/-$/", "")}"
}

resource "google_project" "activator" {
  name = "${local.activator_project_name}"
  project_id = "${local.activator_project_name}"
  folder_id = "${replace(var.activator_folder_id, "folders/" , "")}"
  auto_create_network = false
  billing_account = "${var.billing_account}"
  labels = {
    review-date = "20190321"
    creation-date = "20190321"
    folder-level-1 = "internal"
    folder-level-2 = "modern_applications"
    folder-level-3 = "tranquility_base"
    folder-level-4 = "activators"
    business-name = "business-name"
    cost-code = "kexxxxxx-xxx"
    project-technical-lead = "not_implemented"
    project-name = "tranquility_base"
    region = "${var.region}"
    project-sponsor = "not_implemented"
    creator = "not_implemented"
  }
}

resource "google_project_services" "activator" {
  project = "${google_project.activator.id}"
  services = "${var.api_services}"
  depends_on = ["google_project.activator"]
}

# Attaching activator project to shared vpc host
resource "google_compute_shared_vpc_service_project" "activator_service_project" {
  host_project    = "${var.shared_vpc_host_project}"
  service_project = "${google_project.activator.name}"
  provider = "google-beta.shared-vpc"
  depends_on = ["google_project_services.activator"]
}


//GKE deployment integrated with shared vpc host
module gke-activator {
 
  source = "../tb-gcp-tr/kubernetes-cluster-creation"

  providers = {
    google            = "google"
    google-beta.shared-vpc = "google-beta.shared-vpc"
  }

  region               = "${var.region}"
  sharedvpc_project_id = "${var.shared_vpc_host_project}"
  sharedvpc_network    = "${var.vpc_name}"

  cluster_project_id              = "${google_project.activator.id}"
  cluster_subnetwork              = "${var.activator_cluster_subnetwork}"
  cluster_service_account         = "${var.cluster_service_account}"
  cluster_name                    = "${var.activator_cluster_name}"
  cluster_pool_name               = "${var.activator_cluster_pool_name}"
  cluster_master_cidr             = "${var.activator_cluster_master_cidr}"
  cluster_master_authorized_cidrs = "${var.activator_cluster_master_authorized_cidrs}"

  apis_dependency                 = "${join(",", google_project_services.activator.*.id)}"
  shared_vpc_dependency           = "${google_compute_shared_vpc_service_project.activator_service_project.id}"
  istio_status			  = "${var.istio_status}"
  gke_pod_network_name     = "${var.gke_pod_network_name}"
  gke_service_network_name = "${var.gke_service_network_name}"

}

resource "google_project" "workspace" {
  name = "${local.workspace_project_name}"
  project_id = "${local.workspace_project_name}"
  folder_id = "${replace(var.activator_folder_id, "folders/" , "")}"
  auto_create_network = false
  billing_account = "${var.billing_account}"
  labels = {
    review-date = "20190321"
    creation-date = "20190321"
    folder-level-1 = "internal"
    folder-level-2 = "modern_applications"
    folder-level-3 = "tranquility_base"
    folder-level-4 = "activators"
    business-name = "business-name"
    cost-code = "kexxxxxx-xxx"
    project-technical-lead = "not_implemented"
    project-name = "tranquility_base"
    region = "${var.region}"
    project-sponsor = "not_implemented"
    creator = "not_implemented"
  }
}

resource "google_project_services" "workspace" {
  project = "${google_project.workspace.id}"
  services = "${var.api_services}"
  depends_on = ["google_project.workspace"]
}

# Attaching activator project to shared vpc host
resource "google_compute_shared_vpc_service_project" "workspace_service_project" {
  host_project    = "${var.shared_vpc_host_project}"
  service_project = "${google_project.workspace.name}"
  provider = "google-beta.shared-vpc"
  depends_on = ["google_project_services.workspace"]
}

resource "google_sourcerepo_repository" "workspace-repo" {
  name = "${local.workspace_project_name}"
  project = "${google_project.workspace.name}"
  depends_on = ["google_project_services.workspace"]
}

//GKE deployment integrated with shared vpc host
module gke-workspace {

  source = "../tb-gcp-tr/kubernetes-cluster-creation"

  providers = {
    google            = "google"
    google-beta.shared-vpc = "google-beta.shared-vpc"
  }

  region               = "${var.region}"
  sharedvpc_project_id = "${var.shared_vpc_host_project}"
  sharedvpc_network    = "${var.vpc_name}"

  cluster_project_id              = "${google_project.workspace.id}"
  cluster_subnetwork              = "${var.workspace_cluster_subnetwork}"
  cluster_service_account         = "${var.cluster_service_account}"
  cluster_name                    = "${var.workspace_cluster_name}"
  cluster_pool_name               = "${var.workspace_cluster_pool_name}"
  cluster_master_cidr             = "${var.workspace_cluster_master_cidr}"
  cluster_master_authorized_cidrs = "${var.workspace_cluster_master_authorized_cidrs}"

  apis_dependency                 = "${join(",", google_project_services.workspace.*.id)}"
  shared_vpc_dependency           = "${google_compute_shared_vpc_service_project.workspace_service_project.id}"
  istio_status			  = "${var.istio_status}"
  gke_pod_network_name     = "${var.gke_pod_network_name}"
  gke_service_network_name = "${var.gke_service_network_name}"

}

module k8s-workspace_context {
  source = "../tb-gcp-tr/k8s-context"

  cluster_name        = "${var.workspace_cluster_name}"
  cluster_project     = "${google_project.workspace.project_id}"
  dependency_var      = "${module.gke-workspace.node_id}"
}

module "run_Jenkins" {
  source = "../tb-common-tr/start_service"

  k8s_template_file = "${path.module}/${var.application_yaml_path}"
  cluster_context = "${module.k8s-workspace_context.context_name}"
  dependency_var = "${module.k8s-workspace_context.k8s-context_id}"
}
