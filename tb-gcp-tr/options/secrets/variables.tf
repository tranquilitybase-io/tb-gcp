variable "terraform_state_bucket" {
  type = string
  description = "Name of the terraform state bucket"
}

variable "cluster_sec_enable_private_nodes" {
  type = string
}

variable "cluster_sec_subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_sec_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_sec_service_account_roles" {
  type        = list(string)
  default     = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
  description = "Service account to associate to the nodes in the cluster"
}

variable "cluster_sec_name" {
  description = "The cluster name"
}

variable "cluster_sec_pool_name" {
  description = "The cluster pool name"
}

variable "cluster_sec_master_cidr" {
  type = string
}

variable "cluster_sec_master_authorized_cidrs" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "cluster_sec_min_master_version" {
  default     = "latest"
  description = "Master node minimal version"
  type        = string
}

variable "istio_status" {
  type    = string
  default = "true"
  #  description = "the default behaviour is to not installed"
}

variable "cluster_sec_oauth_scope" {
  description = "API scope to be given to Security Cluster, for vault leave default value"
  default     = ["cloud-platform"]
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