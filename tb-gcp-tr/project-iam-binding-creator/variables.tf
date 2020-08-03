variable "project" {
  description = "Project ID of logging project"
  default     = ""
  type        = string
}
variable "members" {
  description = "List of log writers which will have permissions to create logs"
  default     = []
}
variable "role" {
  description = "Log creating permissions to assign to members"
  default     = ""
  type        = string
}