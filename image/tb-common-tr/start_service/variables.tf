variable "cluster_config_path" {
  description = "Configuration file for kubernetes cluster"
  default = "$HOME/.kube/config"
}

variable "cluster_context" {
  description = "GKE context name"
  default = ""
  type = "string"
}

variable "k8s_template_file" {
  description = "YAML file containing kubernetes deployment"
  type = "string"
}

variable "dependency_var" {
  description = "Variable used only for dependency tracking"
  default = "empty"
  type = "string"
}

