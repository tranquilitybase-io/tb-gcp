cluster_itsm_subnetwork           = "shared-itsm-snet"
cluster_itsm_service_account      = "kubernetes-itsm"
cluster_itsm_name                 = "gke-itsm"
cluster_itsm_pool_name            = "gke-itsm-node-pool"
cluster_itsm_enable_private_nodes = "true"
cluster_itsm_master_cidr          = "172.16.0.32/28"
cluster_itsm_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-1"
  }
]

istio_status        = "false"
gke_pod_network_name     = "gke-pods-snet"
gke_service_network_name = "gke-services-snet"
