cluster_opt_subnetwork           = "shared-operations-snet"
cluster_opt_service_account      = "kubernetes-opt"
cluster_opt_name                 = "gke-opt"
cluster_opt_pool_name            = "gke-opt-node-pool"
cluster_opt_enable_private_nodes = "true"
cluster_opt_master_cidr          = "172.16.0.32/28"
cluster_opt_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]

istio_status        = "false"
gke_pod_network_name     = "gke-pods-snet"
gke_service_network_name = "gke-services-snet"

