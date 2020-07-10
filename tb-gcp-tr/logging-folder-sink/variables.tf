
variable "sink_name" {
  description = "Name of the sink being deployed."
  type        = string
}

variable "destination" {
  description = "The bucket to store the logs in."
  type        = string
}

variable "filter" {
  description = "The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs."
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "The ID of the GCP resource in which you create the log sink. If var.parent_resource_type is set to 'project', then this is the Project ID (and etc)."
  type        = string
}

variable "include_children" {
  type        = bool
  default     = true
  description = "Whether to include logs from child resources."
}

