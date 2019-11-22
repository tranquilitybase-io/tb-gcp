variable "project_id" {
  description = "ID of project to set up the infrastructure on"
  default = "gft-application-dev"
}

variable "region" {
  description = "Zone for GCE resources"
  default = "europe-west2"
}

variable "zone" {
  description = "Zone for activator resources"
  default = "europe-west2-a"
}

variable "activator_folder_id" {
  description = "activator folder id"
}

variable "billing_account" {
  description = "Billing account used for project creation etc"
}

variable "activator_project_name" {
  description = "Name for activator project"
  default = "activator"
}

variable "workspace_project_name" {
  description = "Name for workspace project containing Jenkins server, git repo and so on"
  default = "workspace"
}

variable "cluster_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "activator_cluster_name" {
  description = "The cluster name"
}

variable "workspace_cluster_name" {
  description = "The cluster name"
}

variable "activator_cluster_pool_name" {
  description = "The cluster pool name"
}

variable "workspace_cluster_pool_name" {
  description = "The cluster pool name"
}

variable "activator_cluster_master_cidr" {
  type = "string"
}

variable "workspace_cluster_master_cidr" {
  type = "string"
}

variable "activator_cluster_master_authorized_cidrs" {
  type = "list"
}

variable "workspace_cluster_master_authorized_cidrs" {
  type = "list"
}

variable "istio_status" {
  type = "string"
  default = "true"
  #  description = "the default behaviour is to not installed"
}

variable vpc_name {
  type = "string"
  default = "shared-network"
  description = "Name for the shared vpc network"
}

variable "api_services" {
  type = "list"
  description = "List of API's needed for activator account"
}

variable "env" {
  type = "string"
  default = "dev"
  description = "Environment type"
}

variable "app_name" {
  type = "string"
  default = "activator-app"
  description = "App name the activator and workspace is dedicated for"
}

variable "shared_vpc_host_project" {
  type = "string"
  description = "Shared vpc host ID"
}

variable "activator_cluster_subnetwork" {
  description = "The subnetwork to host the activator cluster in"
}

variable "gke_pod_network_name" {
  type        = "string"
  default     = "gke-pods-snet"
  description = "Name for the gke pod network"
}

variable "gke_service_network_name" {
  type        = "string"
  default     = "gke-services-snet"
  description = "Name for the gke service network"
}

variable "workspace_cluster_subnetwork" {
  description = "The subnetwork to host the workspace cluster in"
}

variable "application_yaml_path" {
  description = "Path to the yaml file describing the application resources"
  type    = "string"
  default = "files/jenkins-deployment.yaml"
}