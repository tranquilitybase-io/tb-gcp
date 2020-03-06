data "terraform_remote_state" "landingzone" {
  backend = "gcs"
  config = {
    bucket  = var.terraform_state_bucket
    prefix  = "landingZone"
  }
}

data "terraform_remote_state" "operations_cluster" {
  backend = "gcs"
  config = {
    bucket  = var.terraform_state_bucket
    prefix  = "operationsCluster"
  }
}

provider "google" {
  region = data.terraform_remote_state.landingzone.outputs.region
  zone   = data.terraform_remote_state.landingzone.outputs.region_zone
  version = "~> 2.5"
}

terraform {
  backend "gcs" {}
}

provider "kubernetes" {
  alias                  = "gke-operations"
  host                   = "https://${data.terraform_remote_state.operations_cluster.outputs.cluster_endpoint}"
  load_config_file       = false
  cluster_ca_certificate = base64decode(data.terraform_remote_state.operations_cluster.outputs.cluster_ca_certificate)
  token                  = data.terraform_remote_state.landingzone.outputs.access_token
  version = "~> 1.10.0"
}

# Deploy gke-operations cluster helm pre-requisite resources
module "gke_operations_helm_pre_req" {
  source = "../../../helm-pre-requisites"
  providers = {
    kubernetes = kubernetes.gke-operations
  }
}

# Set GKE Operations cluster Helm provider
provider "helm" {
  alias = "gke-operations"
  kubernetes {
    host                   = "https://${data.terraform_remote_state.operations_cluster.outputs.cluster_endpoint}"
    load_config_file       = false
    cluster_ca_certificate = base64decode(data.terraform_remote_state.operations_cluster.outputs.cluster_ca_certificate)
    token                  = data.terraform_remote_state.landingzone.outputs.access_token
  }
  service_account = module.gke_operations_helm_pre_req.tiller_svc_accnt_name
  version = "~> 0.10.4"
}

module "itop" {
  source = "../../../itop"
  providers = {
    kubernetes = kubernetes.gke-operations
    helm       = helm.gke-operations
  }

  host_project_id       = data.terraform_remote_state.landingzone.outputs.shared_operations_id
  itop_chart_local_path = "../../../itop/helm"
  region                = data.terraform_remote_state.landingzone.outputs.region
  region_zone           = data.terraform_remote_state.landingzone.outputs.region_zone
  database_user_name    = var.itop_database_user_name
  k8_cluster_name       = var.cluster_opt_name

  dependency_vars = data.terraform_remote_state.operations_cluster.outputs.node_id
}