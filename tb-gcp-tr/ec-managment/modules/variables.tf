variable "parent_id" {
}

variable "billing_id" {
}

variable "region" {
  default = "eu-west1"
}

variable "project_roles" {
  default = [
    "compute.instanceAdmin.v1",
    "storage.admin",
    "source.admin",
    "logging.logWriter",
    "logging.configWriter"
  ]
}

variable "folder_roles" {
  default = [
    "resourcemanager.folderAdmin",
    "resourcemanager.projectCreator",
    "resourcemanager.projectDeleter",
    "billing.projectManager",
    "compute.networkAdmin",
    "compute.xpnAdmin",
    "compute.networkUser",
    "cloudkms.admin",
    "logging.logWriter",
    "logging.configWriter"
  ]
}

variable "project_apis" {
  default = [
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "deploymentmanager.googleapis.com",
    "logging.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
    "storage-api.googleapis.com",
    "runtimeconfig.googleapis.com"
  ]
}