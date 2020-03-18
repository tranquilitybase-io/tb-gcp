data "terraform_remote_state" "landingzone" {
  backend = "gcs"
  config = {
    bucket  = var.terraform_state_bucket
    prefix  = "landingZone"
  }
}

data "terraform_remote_state" "itsm_cluster" {
  backend = "gcs"
  config = {
    bucket  = var.terraform_state_bucket
    prefix  = "options/itsm"
  }
}

provider "google" {
  region = data.terraform_remote_state.landingzone.outputs.region
  zone   = data.terraform_remote_state.landingzone.outputs.region_zone
  version = "~> 2.5"
}

terraform {
  backend "gcs"  {
    bucket  = var.terraform_state_bucket
    prefix  = "options/itsm/itop"
  }
}

provider "kubernetes" {
  alias                  = "gke-itsm"
  host                   = "https://${data.terraform_remote_state.itsm_cluster.outputs.cluster_endpoint}"
  load_config_file       = false
  cluster_ca_certificate = base64decode(data.terraform_remote_state.itsm_cluster.outputs.cluster_ca_certificate)
  token                  = data.terraform_remote_state.landingzone.outputs.access_token
  version = "~> 1.10.0"
}

# Deploy gke-itsm cluster helm pre-requisite resources
module "gke_itsm_helm_pre_req" {
  source = "../../../helm-pre-requisites"
  providers = {
    kubernetes = kubernetes.gke-itsm
  }
}

# Set GKE Itsm cluster Helm provider
provider "helm" {
  alias = "gke-itsm"
  kubernetes {
    host                   = "https://${data.terraform_remote_state.itsm_cluster.outputs.cluster_endpoint}"
    load_config_file       = false
    cluster_ca_certificate = base64decode(data.terraform_remote_state.itsm_cluster.outputs.cluster_ca_certificate)
    token                  = data.terraform_remote_state.landingzone.outputs.access_token
  }
  service_account = module.gke_itsm_helm_pre_req.tiller_svc_accnt_name
  version = "~> 0.10.4"
}

module "itop" {
  source = "./itop-module"
  providers = {
    kubernetes = kubernetes.gke-itsm
    helm       = helm.gke-itsm
  }

  host_project_id       = data.terraform_remote_state.landingzone.outputs.shared_itsm_id
  itop_chart_local_path = "./itop-module/helm"
  region                = data.terraform_remote_state.landingzone.outputs.region
  region_zone           = data.terraform_remote_state.landingzone.outputs.region_zone
  database_user_name    = var.itop_database_user_name
  k8_cluster_name       = var.cluster_itsm_name

  dependency_vars = data.terraform_remote_state.itsm_cluster.outputs.node_id
}