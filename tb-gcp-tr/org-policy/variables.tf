variable "org_id" {
  type        = string
  description = "GCP Organization ID for applying policies"
}

variable "folder_id" {
  type        = string
  description = "GCP Folder for applying policies"
  default     = null
}

variable "project_id" {
  type        = string
  description = "GCP Project ID for applying policies"
  default     = null
}

variable "policy_file_name" {
  type        = string
  description = "Policy YAML file"
  default     = "policies.yaml"
}
