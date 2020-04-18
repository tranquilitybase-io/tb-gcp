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

# Create GCS bucket
# Create public IP for incress service
# Create KMS Keyring and key
# Create service account
# Apply IAM permissions to service account
# Create GKE cluster on shared VPC and apply firewall tag to allow public access
# Deploy Vault
# values are passed in with an input file currently but should be intergrated with the
# gcp project where the cluster resides for vault

############ Providers config for kubernetes ####################
# Query the client configuration for our current service account, which shoudl
# have permission to talk to the GKE cluster since it created it.
data "google_client_config" "current" {
}

# This file contains all the interactions with Kubernetes
provider "kubernetes" {
  load_config_file = false
  host             = var.vault-gke-sec-endpoint
  alias            = "vault"

  cluster_ca_certificate = base64decode(var.vault-gke-sec-cluster_ca_cert)
  token                  = data.google_client_config.current.access_token
  version = "~> 1.10.0"
}

resource "null_resource" "apis_dependency" {
  triggers = {
    apis = var.apis_dependency
  }
}

# Generate servcie account key
resource "google_service_account_key" "vault" {
  service_account_id = var.vault-sa
}

# GCS storage bucket for vault backend
resource "google_storage_bucket" "vault" {
  name          = "${var.vault_cluster_project}-vault-storage"
  project       = var.vault_cluster_project
  location      = var.vault-gcs-location
  force_destroy = true
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      num_newer_versions = 1
    }
  }
}

# Grant service account access to the storage bucket
resource "google_storage_bucket_iam_member" "vault-server" {
  count  = length(var.storage_bucket_roles)
  bucket = google_storage_bucket.vault.name
  role   = element(var.storage_bucket_roles, count.index)
  member = "serviceAccount:${var.vault-sa}"
}

# Create the KMS key ring
resource "google_kms_key_ring" "vault" {
  name       = var.vault_keyring_name
  location   = var.vault-region
  project    = var.vault_cluster_project
  depends_on = [null_resource.apis_dependency]
}

# Create the crypto key for encrypting init keys
resource "google_kms_crypto_key" "vault-init" {
  name            = var.vault_crypto_key_name
  key_ring        = google_kms_key_ring.vault.id
  rotation_period = "604800s"
}

# Create a custom IAM role with the most minimal set of permissions for the
# KMS auto-unsealer. Once hashicorp/vault#5999 is merged, this can be replaced
# with the built-in roles/cloudkms.cryptoKeyEncrypterDecryptor role.
resource "google_project_iam_custom_role" "vault-seal-kms" {
  project     = var.vault_cluster_project
  role_id     = "kmsEncrypterDecryptorViewer"
  title       = "KMS Encrypter Decryptor Viewer"
  description = "KMS crypto key permissions to encrypt, decrypt, and view key data"

  # cloudkms.cryptoKeys.get below is required until hashicorp/vault#5999 is merged.
  # The auto-unsealer attempts to read the key, which requires this additional permission.
  permissions = [
    "cloudkms.cryptoKeyVersions.useToEncrypt",
    "cloudkms.cryptoKeyVersions.useToDecrypt",
    "cloudkms.cryptoKeys.get",
  ]
}

# Grant service account access to the key
resource "google_kms_crypto_key_iam_member" "vault-init" {
  crypto_key_id = google_kms_crypto_key.vault-init.id
  role          = "projects/${var.vault_cluster_project}/roles/${google_project_iam_custom_role.vault-seal-kms.role_id}"
  member        = "serviceAccount:${var.vault-sa}"
}

# Provision IP
resource "google_compute_address" "vault" {
  name    = var.vault-lb
  region  = var.vault-region
  project = var.vault_cluster_project
}

############### TLS Cert config ####################

# Generate self-signed TLS certificates. Unlike @kelseyhightower's original
# demo, this does not use cfssl and uses Terraform's internals instead.
resource "tls_private_key" "vault-ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "vault-ca" {
  key_algorithm   = tls_private_key.vault-ca.algorithm
  private_key_pem = tls_private_key.vault-ca.private_key_pem

  subject {
    common_name  = var.vault-cert-common-name
    organization = var.vault-cert-organization
  }

  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > ../../vault/tls/ca.pem && chmod 0600 ../../vault/tls/ca.pem"
  }
}

# Create the Vault server certificates
resource "tls_private_key" "vault" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > ../../vault/tls/vault.key && chmod 0600 ../../vault/tls/vault.key"
  }
}

# Create the request to sign the cert with our CA
resource "tls_cert_request" "vault" {
  key_algorithm   = tls_private_key.vault.algorithm
  private_key_pem = tls_private_key.vault.private_key_pem

  dns_names = [
    "vault",
    "vault.local",
    "vault.default.svc.cluster.local",
  ]

  ip_addresses = [
    google_compute_address.vault.address,
  ]

  subject {
    common_name  = var.vault-cert-common-name
    organization = var.vault-cert-organization
  }
}

# Now sign the cert
resource "tls_locally_signed_cert" "vault" {
  cert_request_pem = tls_cert_request.vault.cert_request_pem

  ca_key_algorithm   = tls_private_key.vault-ca.algorithm
  ca_private_key_pem = tls_private_key.vault-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.vault-ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
    "client_auth",
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > ../../vault/tls/vault.pem && echo '${tls_self_signed_cert.vault-ca.cert_pem}' >> ../../vault/tls/vault.pem && chmod 0600 ../../vault/tls/vault.pem"
  }
}

#################### K8s Config ###############################

# Write the secret
resource "kubernetes_secret" "vault-tls" {
  provider = kubernetes.vault
  metadata {
    name = "vault-tls"
  }

  data = {
    "vault.crt" = "${tls_locally_signed_cert.vault.cert_pem}\n${tls_self_signed_cert.vault-ca.cert_pem}"
    "vault.key" = tls_private_key.vault.private_key_pem
    "ca.crt"    = tls_self_signed_cert.vault-ca.cert_pem
  }
}

locals {
  proxy_command = "gcloud compute ssh proxyuser@tb-kube-proxy --quiet --project=${var.shared_bastion_project} --zone=europe-west2-a --command"
}

#proxy_command1 = "gcloud compute ssh proxyuser@tb-kube-proxy --quiet --project=${var.shared_bastion_project} --zone=europe-west2-a --command="
#gcloud compute ssh proxyuser@tb-kube-proxy --quiet --project="${var.shared_bastion_project}" --zone="europe-west2-a" --command="gcloud container clusters get-credentials gke-sec --region=europe-west2 --project="${var.vault_cluster_project}" --internal-ip"

resource "null_resource" "test-ssh" {

  provisioner "local-exec" {
    command = <<EOF
${local.proxy_command}="gcloud compute instances list"
${local.proxy_command}="gcloud container clusters get-credentials gke-sec --region=europe-west2 --project="${var.vault_cluster_project}" --internal-ip"
gcloud compute ssh proxyuser@tb-kube-proxy --quiet --project="${var.shared_bastion_project}" --zone="europe-west2-a" --command="kubectl get nodes"

EOF

  }
}

resource "null_resource" "apply" {
  triggers = {
    host                   = md5(var.vault-gke-sec-endpoint)
    username               = md5(var.vault-gke-sec-username)
    password               = md5(var.vault-gke-sec-password)
    client_certificate     = md5(var.vault-gke-sec-client-ca)
    client_key             = md5(var.vault-gke-sec-client-key)
    cluster_ca_certificate = md5(var.vault-gke-sec-cluster_ca_cert)
  }

  depends_on = [kubernetes_secret.vault-tls]

  provisioner "local-exec" {
    command = <<EOF
gcloud compute ssh proxyuser@tb-kube-proxy --quiet --project="${var.shared_bastion_project}" --zone="europe-west2-a" --command="gcloud container clusters get-credentials "${var.vault-gke-sec-name}" --region="${var.vault-region}" --project="${var.vault_cluster_project}" --internal-ip"

CONTEXT="gke_${var.vault_cluster_project}_${var.vault-region}_${var.vault-gke-sec-name}"
echo '${templatefile("${path.module}/../vault/k8s/vault.yaml", {
    load_balancer_ip         = google_compute_address.vault.address
    num_vault_pods           = var.num_vault_pods
    vault_container          = var.vault_container
    vault_init_container     = var.vault_init_container
    vault_recovery_shares    = var.vault_recovery_shares
    vault_recovery_threshold = var.vault_recovery_threshold
    project                  = google_kms_key_ring.vault.project
    kms_region               = google_kms_key_ring.vault.location
    kms_key_ring             = google_kms_key_ring.vault.name
    kms_crypto_key           = google_kms_crypto_key.vault-init.name
    gcs_bucket_name          = google_storage_bucket.vault.name
  })}' | gcloud compute ssh proxyuser@tb-kube-proxy --quiet --project="${var.shared_bastion_project}" --zone="europe-west2-a" --command="kubectl apply --context="$CONTEXT" -f -"
EOF

  }
}
#gcloud compute ssh proxyuser@tb-kube-proxy --quiet --project="${var.shared_bastion_project}" --zone="europe-west2-a" -- -v -L 8118:localhost:8118

#export HTTPS_PROXY=localhost:8118

#gcloud container clusters get-credentials "${var.vault-gke-sec-name}" --region="${var.vault-region}" --project="${var.vault_cluster_project}" --internal-ip

# Wait for all the servers to be ready
resource "null_resource" "wait-for-finish" {
  provisioner "local-exec" {
    command = <<EOF
for i in $(seq -s " " 1 42); do
  sleep $i
  CONTEXT="gke_${var.vault_cluster_project}_${var.vault-region}_${var.vault-gke-sec-name}"
  if [ $(kubectl --context="$CONTEXT" get pod -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}' | wc -w) -eq ${var.num_vault_pods} ]; then
    exit 0
  fi
done

echo "Pods are not ready after 15m3s."
exit 1
EOF

  }

  depends_on = [null_resource.apply]
}

# Build the URL for the keys on GCS
data "google_storage_object_signed_url" "keys" {
  bucket = google_storage_bucket.vault.name
  path   = "root-token.enc"

  credentials = base64decode(google_service_account_key.vault.private_key)

  depends_on = [null_resource.wait-for-finish]
}

# Download the encrypted recovery unseal keys and initial root token from GCS
data "http" "keys" {
  url = data.google_storage_object_signed_url.keys.signed_url
}

# Decrypt the values
data "google_kms_secret" "keys" {
  crypto_key = google_kms_crypto_key.vault-init.id
  ciphertext = data.http.keys.body
}

# Output the initial root token
output "root_token" {
  value = data.google_kms_secret.keys.plaintext
}

# Output when vault is running on k8s
output "is_running" {
  value = null_resource.wait-for-finish.id != "" # Always returns true
}

