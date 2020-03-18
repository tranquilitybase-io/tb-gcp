variable "terraform_state_bucket" {
  description = "Landing Zone terraform state bucket name"
}

variable "itop_database_user_name" {
  description = "iTop's database user account name"
  default     = "itop"
  type        = string
}

variable "cluster_itsm_name" {
  description = "The cluster name"
}

