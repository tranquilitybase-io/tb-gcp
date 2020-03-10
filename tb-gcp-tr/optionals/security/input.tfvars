cluster_sec_subnetwork           = "shared-security-snet"
cluster_sec_service_account      = "kubernetes-sec"
cluster_sec_name                 = "gke-sec"
cluster_sec_pool_name            = "gke-sec-node-pool"
cluster_sec_enable_private_nodes = "true"
cluster_sec_master_cidr          = "172.16.0.16/28"
cluster_sec_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]

istio_status        = "false"
gke_pod_network_name     = "gke-pods-snet"
gke_service_network_name = "gke-services-snet"
