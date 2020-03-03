#FOLDER STRUCTURE CREATION
variable "shared_vpc_name" {
  type        = string
  default     = "shared-network"
  description = "Name for the shared vpc network"
}

variable "cluster_opt_enable_private_nodes" {
  type = string
}

variable "cluster_opt_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_opt_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_opt_name" {
  description = "The cluster name"
}

variable "shared_networking_id" {
  description = "shared networking project ID"
}

variable "cluster_opt_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_opt_master_cidr" {
  type = string
}

variable "cluster_opt_master_authorized_cidrs" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "clusters_master_whitelist_ip" {
  description = "IP to add to the GKE clusters' master authorized networks"
  type        = string
}

variable "cluster_opt_min_master_version" {
  default     = "latest"
  description = "Master node minimal version"
  type        = string
}

variable "istio_status" {
  type    = string
  default = "true"
  #  description = "the default behaviour is to not installed"
}

variable "gke_pod_network_name" {
  type        = string
  default     = "gke-pods-snet"
  description = "Name for the gke pod network"
}

variable "gke_service_network_name" {
  type        = string
  default     = "gke-services-snet"
  description = "Name for the gke service network"
}

variable "terraform_state_bucket" {
  type = string
  description = "Name of the terraform state bucket"
}
