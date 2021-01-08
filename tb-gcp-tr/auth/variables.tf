variable "content" {
  description = "Content for the Trigger"
  type        = string
}

variable "context_name" {
  description = "GKE context name stored into ~/.kube/config"
  tyoe        = string
}

variable "project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "region" { 
  description = "region"
  type        = string
}

variable "domain_name" {
  description = "domain"
  type        = string
}