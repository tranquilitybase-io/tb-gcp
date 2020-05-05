# SHARED VPC
variable "shared_vpc_name" {
  type        = string
  default     = "shared-network"
  description = "Name for the shared vpc network"
}

variable "region_zone" {
  type        = string
  description = "zone name in the region provided."
}

#FOLDER STRUCTURE CREATION
variable "region" {
  type        = string
  description = "region name."
}

variable "shared_bastion_id" {
  type        = string
  description = "TB Bastion ID"
}

variable "shared_networking_id" {
  type        = string
  description = "identifier for the shared_networking project."
}

variable "nat_static_ip" {
  type = string
  description = "NAT Static IP"
}

variable root_id {
  type = string
  description = "ID for the parent organisation where folders will be created"
}

variable "scopes" {
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
  description = "A list of service scopes attached to the bootstrap terraform server. To allow full access to all Cloud APIs, use the cloud-platform scope. For other scopes see here: https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes "
}

variable "main_iam_service_account_roles" {
  type = list(string)
  default = [
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectDeleter",
    "roles/billing.projectManager",
    "roles/compute.xpnAdmin",
    "roles/owner",
    "roles/compute.networkAdmin",
  ]
  description = "Roles attached to service account"
}
variable "shared_bastion_project_number" {
  type = string
}