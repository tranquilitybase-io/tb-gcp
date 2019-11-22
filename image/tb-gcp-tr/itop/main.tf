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

resource "null_resource" "dependencies_waiter" {
  triggers = {
    dependency_vars = "${var.dependency_vars}"
  }
}

resource "random_id" "db_name_suffix" {
  # deleting an instance takes a week therefore
  # its best to use the random-id suffix
  byte_length = 4
}

# Create the CloudSQL database instance
resource "google_sql_database_instance" "master" {
  project = "${data.google_project.host-project.project_id}"
  name = "${var.database_instance_name}-${random_id.db_name_suffix.hex}"
  database_version = "${var.database_version}"
  region = "${var.region}"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "${var.database_tier}"
  }
}

# Generate a random password for itop's DB user account
resource "random_password" "itop_db_user_password" {
  length = 24
}

resource "google_sql_user" "users" {
  name     = "${var.database_user_name}"
  instance = "${google_sql_database_instance.master.name}"
  password = "${random_password.itop_db_user_password.result}"
  project  = "${var.host_project_id}"
  host     = "cloudsqlproxy~%"
}

# Create the itop namespace
# set the label istio-injection=enabled into the namespace
# so that any pods we install into this namespace will be injected with the istio sidcar proxy
resource "kubernetes_namespace" "ns" {
  metadata {
    name = "${var.itop_namespace}"

    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = ["null_resource.dependencies_waiter"]
}

# Put the CloudProxy svc account key (created in IAM) into the Kubernetes secret
resource "kubernetes_secret" "sql-proxy-sa-credentials" {
  metadata = {
    name = "cloudsql-proxy-sa-credentials"
    namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  }
  data {
    cloudsql-proxy-sa-credentials.json = "${base64decode(google_service_account_key.sql-proxy-sa-key.private_key)}"
  }

  depends_on = ["null_resource.dependencies_waiter"]
}

# install the helm itop helm charts
resource "helm_release" "itop" {
  name       = "itop"
  repository = "${var.itop_chart_local_path}"
  chart      = "itop"
  namespace  = "${kubernetes_namespace.ns.metadata.0.name}"

  set {
    name  = "cloudSqlProxySidecar.instanceConnectionName"
    value = "${google_sql_database_instance.master.connection_name}"
  }

  set {
    name  = "cloudSqlProxySidecar.databaseInstanceName"
    value = "${google_sql_database_instance.master.name}"
  }

  set {
    name  = "istioServiceEntry.cloudSqlInstanceIp"
    value = "${google_sql_database_instance.master.public_ip_address}"
  }

  set {
    name  = "replicaCount"
    value = "${var.itop_replica_count}"
  }

  set {
    name  = "image.repository"
    value = "${var.itop_image_repository}"
  }

  set {
    name  = "image.tag"
    value = "${var.itop_image_tag}"
  }

  depends_on = ["null_resource.dependencies_waiter"]
}
