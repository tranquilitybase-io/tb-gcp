variable "terraform_state_bucket_name" {
  type = string
  description = "Name of the terraform state bucket"
}

variable "location" {
  type    = string
  default = "EU"
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "region name."
}

variable "sec-vault-keyring" {
  type = string
}

variable "sec-vault-crypto-key-name" {
  type = string
}

variable "sec-lb-name" {
  type = string
}

variable "cluster_sec_name" {
  description = "The cluster name"
}

variable "cert-common-name" {
  type = string
}

variable "tls-organization" {
  type = string
}

variable "vault-lb-name" {
  type = string
}
