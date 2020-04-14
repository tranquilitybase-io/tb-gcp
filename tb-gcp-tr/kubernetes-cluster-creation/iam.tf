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

# separate google-beta provider needed to assign sharedvpc networkUser permissions
provider "google" {
  version = "~> 2.5"
}

provider "google-beta" {
  alias = "shared-vpc"
  version = "~> 2.5"
}


provider "google" {
  version = "~> 3.17"
  alias = "google-3"
}

provider "google-beta" {
  version = "~> 3.17"
  alias = "google-beta-3"
}

# create compute service account for kubernetes cluster
resource "google_service_account" "cluster" {
  account_id   = var.cluster_service_account
  display_name = "${var.cluster_service_account} service account"
  project      = var.cluster_project_id
}

# assign iam permissions to cluster service account

resource "google_project_iam_member" "cluster_serviceAccount" {
  count   = length(var.cluster_service_account_roles)
  project = var.cluster_project_id
  role    = var.cluster_service_account_roles[count.index]
  member  = format("serviceAccount:%s", google_service_account.cluster.email)
}

# assign default service agent permission in service project
/*
resource "google_project_iam_member" "cluster_serviceAgent" {
  project = "${var.cluster_project_id}"
  role    = "roles/container.serviceAgent"
  member  = "${format("serviceAccount:%s", google_service_account.cluster.email)}"
}
*/

resource "null_resource" "api_enabled" {
  triggers = {
    vpc_name = var.apis_dependency
  }
}

# refer to https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
resource "google_project_iam_member" "cluster_hostServiceAgentUser" {
  project = var.sharedvpc_project_id
  role    = "roles/container.hostServiceAgentUser"
  member = format(
    "serviceAccount:service-%s@container-engine-robot.iam.gserviceaccount.com",
    data.google_project.cluster.number,
  )
  depends_on = [null_resource.api_enabled]
}

# grant access to subnetwork with networkUser permissions to cluster service account in shared-vpc
resource "google_compute_subnetwork_iam_member" "cluster_networkUser_1" {
  provider   = google-beta.shared-vpc
  subnetwork = var.cluster_subnetwork
  role       = "roles/compute.networkUser"
  member = format(
    "serviceAccount:%s@cloudservices.gserviceaccount.com",
    data.google_project.cluster.number,
  )
  depends_on = [null_resource.api_enabled]
}

resource "google_compute_subnetwork_iam_member" "cluster_networkUser_2" {
  provider   = google-beta.shared-vpc
  subnetwork = var.cluster_subnetwork
  role       = "roles/compute.networkUser"
  member = format(
    "serviceAccount:service-%s@container-engine-robot.iam.gserviceaccount.com",
    data.google_project.cluster.number,
  )
  depends_on = [null_resource.api_enabled]
}

