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