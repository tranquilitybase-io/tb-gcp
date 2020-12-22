
variable "content" {
  description = "Content for the Trigger"
}

variable "context_name" {
  description = "GKE context name stored into ~/.kube/config"
}

variable "project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "region" { 
    description = "region"
    type        = string
}