//Project
variable "project_id" {
  description = "ID of project to set up the infrastructure on"
  default     = "gft-operations-cicd-pipelines"
}

variable "region" {
	description = "Region for cluster"
	default = "europe-west2"
}

variable "zone" {
	description = "Zone for GCE resources"
	default = "europe-west2-b"
}

//Cluster
variable "cluster_name" {
	description = "Name of cluster"
	default = "cd-jenkins"
}

variable "username" {
	description = "Admin username for cluster"
	default = "usernameformasterauth"
}

variable "password" {
	description = "Admin password for cluster"
	default = "passwordmustbe16characters"
}

variable "cluster_machine_type" {
	description = "GCE machine type used by cluster"
	default = "n1-standard-2"
}

//Bastion Host
variable "bastion_machine_type" {
	description = "GCE machine type for basion"
	default = "g1-small"
}

variable "bastion_name" {
	description = "Name of bastion host"
	default = "jenkins-bastion-host"
}

variable "source_repository" {
	default = "JenkinsGKE"
	description = "Source Repository used by Bastion"
}