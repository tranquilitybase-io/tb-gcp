variable "region" {
  type        = string
  default     = "europe-west2"
  description = "Region name."
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "router_name" {
  type        = string
  default     = "vpc-network-router"
  description = "Cloud NAT router name"
}

variable "router_nat_name" {
  type        = string
  default     = "vpc-network-nat-gateway"
  description = "Cloud NAT gateway name"
}

variable "vpc_name" {
  type        = string
  default     = "bootstrap"
  description = "bootstrap network name"
}
variable "fw_name" {
  type        = string
  description = "firewall rule name"
}