# SHARED VPC
variable "shared_vpc_name" {
  type        = string
  default     = "shared-network"
  description = "Name for the shared vpc network"
}

variable "region_zone" {
  type        = string
  default     = "europe-west2-a"
  description = "zone name in the region provided."
}

#FOLDER STRUCTURE CREATION
variable "region" {
  type        = string
  default     = "europe-west2"
  description = "region name."
}

variable "tb_bastion_id" {
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