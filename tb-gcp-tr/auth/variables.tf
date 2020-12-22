variable "client_id" {
  description = "this is client's Id"
}

variable "client_secret" {
  description = "Client's (password)"
  type        = string
}

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

variable "credentials" {
  description = "google credentials"
  type        = string
}

variable "region"{
    description =" region"
}