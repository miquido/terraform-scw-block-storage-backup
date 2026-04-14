variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "project_id" {
  type = string
}

variable "organization_id" {
  type = string
}

variable "region" {
  type    = string
  default = "pl-waw"
}

variable "volume_id" {
  type        = string
  description = "ID of the block volume to snapshot"
}

variable "schedule" {
  type        = string
  description = "Cron expression (UTC)"
  default     = "0 2 * * *"
}

variable "retention_count" {
  type        = number
  description = "Number of snapshots to keep (oldest are deleted)"
  default     = 7
}