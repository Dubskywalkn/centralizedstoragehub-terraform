variable "principal_id" { type = string }
variable "resource_group_name" {type = string }
variable "storage_account_name" { type = string }
variable "container_names" { type = set(string) }

variable "role_name" {
  description = "Role to assign"
  type        = string
  default     = "Storage Blob Data Contributor"
}
