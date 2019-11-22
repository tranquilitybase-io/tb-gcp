variable "istio_version" {
  description = "Istio version in form X.Y.Z (default value: '1.1.6'). It is used to select proper Istio Helm chart from https://storage.googleapis.com/istio-release/releases/X.Y.Z/charts/"
  default = "1.1.6"
  type = "string"
}

variable "kubernetes_config_path" {
  description = "Configuration file for kubernetes cluster"
  default = "~/.kube/config"
  type = "string"
}
//
//variable "istio_configuration_adjustment_path" {
//  description = "YAML file containing Istio installation configuration adjustements for Kubernetes over the default configuration (see: https://istio.io/docs/reference/config/installation-options/)."
//  default = "files/default_values_adjustemnt.yaml"
//  type = "string"
//}

variable "dependency_var" {
  description = "Variable used only for dependency tracking"
  default = "1"
  type = "string"
}

variable "endpoint_file" {
  description = "File where to write the output"
  default = ""
  type = "string"
}