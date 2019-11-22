api_services = ["compute.googleapis.com", "oslogin.googleapis.com", "container.googleapis.com", "storage-api.googleapis.com",
  "sourcerepo.googleapis.com", "cloudresourcemanager.googleapis.com", "cloudbilling.googleapis.com", "serviceusage.googleapis.com",
  "datastore.googleapis.com"]

#KUBERNETES ACTIVATOR CLUSTER
vpc_name = "shared-network"
activator_cluster_subnetwork = "activator-project-snet"
cluster_service_account = "kubernetes-ssp"
activator_cluster_name = "gke-activator"
activator_cluster_pool_name = "gke-activator-node-pool"
activator_cluster_master_cidr ="172.16.0.0/28"
activator_cluster_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-activator"
  }
]
istio_status = "false"

#Cloud Source Repository
activator_repo_name = "activator-repo"

workspace_cluster_subnetwork = "workspace-project-snet"
workspace_cluster_name = "gke-workspace"
workspace_cluster_pool_name = "gke-activator-node-pool"
workspace_cluster_master_cidr ="172.48.0.0/28"
workspace_cluster_master_authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8"
    display_name = "mgmt-workspace"
  }
]