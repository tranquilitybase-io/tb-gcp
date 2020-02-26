provider "google" {
  alias  = "vault"
  region = var.region
  zone   = var.region_zone
  version = "~> 2.5"
}

provider "google-beta" {
  alias   = "shared-vpc"
  region  = var.region
  zone    = var.region_zone
  project = module.shared_projects.shared_networking_id
  version = "~> 2.5"
}

provider "kubernetes" {
  alias = "k8s"
  version = "~> 1.10.0"
}

terraform {
  backend "gcs" {
    # The bucket name below is overloaded at every run with
    # `-backend-config="bucket=${terraform_state_bucket_name}"` parameter
    # templated into the `bootstrap.sh` script
    bucket = "terraformdevstate"
  }
}

module "gke-operations" {
  source = "../../kubernetes-cluster-creation"

  providers = {
    google                 = google
    google-beta.shared-vpc = google-beta.shared-vpc
    kubernetes             = kubernetes.gke-operations
  }

  region               = var.region
  sharedvpc_project_id = module.shared_projects.shared_networking_id
  sharedvpc_network    = var.shared_vpc_name

  cluster_enable_private_nodes = var.cluster_opt_enable_private_nodes
  cluster_project_id           = module.shared_projects.shared_operations_id
  cluster_subnetwork           = var.cluster_opt_subnetwork
  cluster_service_account      = var.cluster_opt_service_account
  cluster_name                 = var.cluster_opt_name
  cluster_pool_name            = var.cluster_opt_pool_name
  cluster_master_cidr          = var.cluster_opt_master_cidr
  cluster_master_authorized_cidrs = concat(
  var.cluster_opt_master_authorized_cidrs,
  [
    merge(
    {
      "display_name" = "initial-admin-ip"
    },
    {
      "cidr_block" = join("", [var.clusters_master_whitelist_ip, "/32"])
    },
    ),
  ],
  )
  cluster_min_master_version = var.cluster_opt_min_master_version

  apis_dependency          = module.apis_activation.all_apis_enabled
  istio_status             = var.istio_status
  istio_permissive_mtls    = "true"
  shared_vpc_dependency    = module.shared-vpc.gke_subnetwork_ids
  gke_pod_network_name     = var.gke_pod_network_name
  gke_service_network_name = var.gke_service_network_name
}