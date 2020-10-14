variable "linux_instances" {
  type    = list(string)
}

variable "windows_instances" {
  type    = list(string)
}

variable "squid_proxy_instances" {
  type    = list(string)
}

variable "zone" {}

variable "private_dns_domain_name" {}

variable "private_dns_name" {}

