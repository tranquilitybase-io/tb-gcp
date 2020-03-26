data "terraform_remote_state" "landingzone" {
  backend = "gcs"
  config = {
    bucket  = var.terraform_state_bucket_name
    prefix  = "landingZone"
  }
}

data "terraform_remote_state" "secrets_cluster" {
  backend = "gcs"
  config = {
    bucket  = var.terraform_state_bucket_name
    prefix  = "options/secrets"
  }
}

provider "google" {
  region = data.terraform_remote_state.landingzone.outputs.region
  zone   = data.terraform_remote_state.landingzone.outputs.region_zone
  version = "~> 2.5"
}

terraform {
  backend "gcs"  {
    bucket  = var.terraform_state_bucket_name
    prefix  = "options/secrets/vault"
  }
}

module "vault" {
  source = "./vault-module"

  vault_cluster_project             = data.terraform_remote_state.landingzone.outputs.shared_secrets_id
  vault-gcs-location                = var.location
  vault-region                      = data.terraform_remote_state.landingzone.outputs.region
  vault_keyring_name                = var.sec-vault-keyring
  vault_crypto_key_name             = var.sec-vault-crypto-key-name
  vault-lb                          = var.sec-lb-name
  vault-sa                          = data.terraform_remote_state.secrets_cluster.outputs.cluster_sa
  vault-gke-sec-endpoint            = data.terraform_remote_state.secrets_cluster.outputs.sec-gke-endpoint
  vault-gke-sec-master-auth-ca-cert = data.terraform_remote_state.secrets_cluster.outputs.sec-gke-endpoint
  vault-gke-sec-username            = data.terraform_remote_state.secrets_cluster.outputs.cluster_master_auth_username
  vault-gke-sec-password            = data.terraform_remote_state.secrets_cluster.outputs.cluster_master_auth_password
  vault-gke-sec-client-ca           = data.terraform_remote_state.secrets_cluster.outputs.cluster_master_auth_0_client_certificate
  vault-gke-sec-client-key          = data.terraform_remote_state.secrets_cluster.outputs.cluster_master_auth_0_client_key
  vault-gke-sec-cluster_ca_cert     = data.terraform_remote_state.secrets_cluster.outputs.cluster_master_auth_0_cluster_ca_certificate
  vault-gke-sec-name                = var.cluster_sec_name

  vault-cert-common-name  = var.cert-common-name
  vault-cert-organization = var.tls-organization

  apis_dependency = data.terraform_remote_state.landingzone.outputs.all_apis_enabled
  #  shared_vpc_dependency = "${module.shared-vpc.gke_subnetwork_ids}"
}