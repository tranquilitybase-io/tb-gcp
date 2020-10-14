variable "linux_instances" {
  type    = set(string)
}

variable "windows_instances" {
  type    = set(string)
}

variable "squid_proxy_instances" {
  type    = set(string)
}

variable "zone" {}

variable "private_dns_domain_name" {}

variable "private_dns_name" {}

