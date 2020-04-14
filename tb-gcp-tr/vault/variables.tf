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

# Vault GCS
variable "vault_cluster_project" {
}

variable "vault-gcs-location" {
}

variable "storage_bucket_roles" {
  type = list(string)

  default = [
    "roles/storage.legacyBucketReader",
    "roles/storage.objectAdmin",
  ]
}

#TLS
variable "vault-cert-organization" {
}

variable "vault-gke-sec-master-auth-ca-cert" {
}

# Vault KMS
variable "vault-region" {
}

variable "vault_keyring_name" {
}

variable "vault-lb" {
}

variable "vault_crypto_key_name" {
}

variable "vault-sa" {
}

variable "apis_dependency" {
}

variable "vault-gke-sec-endpoint" {
}

variable "vault-cert-common-name" {
}

variable "num_vault_pods" {
  type    = string
  default = "3"

  description = <<EOF
Number of Vault pods to run. Anti-affinity rules spread pods across available
nodes. Please use an odd number for better availability.
EOF

}

variable "vault_container" {
  type    = string
  default = "vault:1.0.1"

  description = <<EOF
Name of the Vault container image to deploy. This can be specified like
"container:version" or as a full container URL.
EOF

}

variable "vault_init_container" {
  type    = string
  default = "sethvargo/vault-init:1.0.0"

  description = <<EOF
Name of the Vault init container image to deploy. This can be specified like
"container:version" or as a full container URL.
EOF

}

variable "vault_recovery_shares" {
  type    = string
  default = "1"

  description = <<EOF
Number of recovery keys to generate.
EOF

}

variable "vault_recovery_threshold" {
  type    = string
  default = "1"

  description = <<EOF
Number of recovery keys required for quorum. This must be less than or equal
to "vault_recovery_keys".
EOF

}

# variable "num_vault_pods" {
#   type    = "string"
#   default = "3"

#   description = <<EOF
# Number of Vault pods to run. Anti-affinity rules spread pods across available
# nodes. Please use an odd number for better availability.
# EOF
# }

# K8s cluster
variable "vault-gke-sec-username" {
}

variable "vault-gke-sec-password" {
}

variable "vault-gke-sec-client-ca" {
}

variable "vault-gke-sec-cluster_ca_cert" {
}

variable "vault-gke-sec-client-key" {
}

variable "vault-gke-sec-name" {
}

variable "shared_bastion_project" {}

