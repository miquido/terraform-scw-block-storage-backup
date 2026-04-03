locals {
  name = "${var.project}-${var.environment}-snapshot-scheduler"
}

resource "scaleway_iam_application" "snapshot_scheduler" {
  name        = local.name
  description = "Creates block volume snapshots on a schedule"
}

resource "scaleway_iam_policy" "snapshot_scheduler" {
  name           = local.name
  application_id = scaleway_iam_application.snapshot_scheduler.id
  rule {
    project_ids          = [var.project_id]
    permission_set_names = ["BlockStorageFullAccess"]
  }
}

resource "scaleway_iam_api_key" "snapshot_scheduler" {
  application_id = scaleway_iam_application.snapshot_scheduler.id
  description    = "Used by snapshot-scheduler job"
}

resource "scaleway_job_definition" "snapshot" {
  name         = local.name
  cpu_limit    = 140
  memory_limit = 256
  image_uri    = "scaleway/cli:latest"
  command      = "/scw block snapshot create volume-id=${element(split("/", var.volume_id), 1)}"
  region       = var.region

  cron {
    schedule = "0 2 * * *"
    timezone = "Europe/Warsaw"
  }

  env = {
    SCW_ACCESS_KEY              = scaleway_iam_api_key.snapshot_scheduler.access_key
    SCW_SECRET_KEY              = scaleway_iam_api_key.snapshot_scheduler.secret_key
    SCW_DEFAULT_PROJECT_ID      = var.project_id
    SCW_DEFAULT_ORGANIZATION_ID = var.organization_id
    SCW_DEFAULT_REGION          = var.region
    SCW_DEFAULT_ZONE            = "${var.region}-1"
  }
}