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

# This module deploys the pre-requisites required for a helm_release resource/module:
# * creates the tiller service account
# * gives it cluster-admin

resource "null_resource" "set_proxy" {
  provisioner "local-exec" {
    command = "export https_proxy=\"localhost:3128\""
  }
}

# Create tiller's service account
resource "kubernetes_service_account" "tiller_svc_accnt" {
  metadata {
    name      = var.tiller_svc_accnt_name
    namespace = "kube-system"
  }
  depends_on = [null_resource.set_proxy]

}

# Setup RBAC for tiller service account
resource "kubernetes_cluster_role_binding" "helm_role_binding" {
  metadata {
    name = kubernetes_service_account.tiller_svc_accnt.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller_svc_accnt.metadata[0].name
    namespace = "kube-system"
  }

  # TODO Depend the provider on the ClusterRoleBinding to avoid the following sleep
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "null_resource" "unset_proxy" {
  provisioner "local-exec" {
    command = "unset https_proxy"
  }
  depends_on = [kubernetes_cluster_role_binding.helm_role_binding]
}

