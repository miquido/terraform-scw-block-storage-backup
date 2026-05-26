locals {
  name            = "${var.project}-${var.environment}-snapshot-scheduler"
  volume_id_short = element(split("/", var.volume_id), 1)

  snapshot_script = base64encode(<<-PYTHON
    import os, urllib.request, json

    secret_key     = os.environ['SCW_SECRET_KEY']
    volume_id      = os.environ['VOLUME_ID']
    zone           = os.environ.get('SCW_DEFAULT_ZONE', 'pl-waw-1')
    retention      = int(os.environ.get('RETENTION_COUNT', '7'))

    base = f'https://api.scaleway.com/block/v1/zones/{zone}'
    headers = {'X-Auth-Token': secret_key, 'Content-Type': 'application/json'}

    from datetime import datetime

    def call(method, path, data=None):
        req = urllib.request.Request(f'{base}{path}', method=method, headers=headers,
                                     data=json.dumps(data).encode() if data else None)
        try:
            with urllib.request.urlopen(req) as r:
                return json.loads(r.read()) if r.status != 204 else None
        except urllib.error.HTTPError as e:
            print(f'HTTP {e.code}: {e.read().decode()}')
            raise

    snapshots = call('GET', f'/snapshots?volume_id={volume_id}&order_by=created_at_desc').get('snapshots', [])

    for snap in snapshots[retention:]:
        call('DELETE', f'/snapshots/{snap["id"]}')
        print(f'Deleted {snap["id"]} ({snap["created_at"]})')

    name = f'backup-{datetime.utcnow().strftime("%Y%m%d-%H%M%S")}'
    new = call('POST', '/snapshots', {'volume_id': volume_id, 'name': name, 'project_id': os.environ['SCW_DEFAULT_PROJECT_ID']})
    print(f'Created {new["id"]}')
  PYTHON
  )
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
  name                   = local.name
  cpu_limit              = 140
  memory_limit           = 256
  local_storage_capacity = 1024
  image_uri              = "python:3-alpine"
  startup_command        = ["python3", "-c", "exec(__import__('base64').b64decode(__import__('os').environ['SNAPSHOT_SCRIPT']).decode())"]
  region                 = var.region

  cron {
    schedule = var.schedule
    timezone = "Europe/Warsaw"
  }

  env = {
    SCW_SECRET_KEY              = scaleway_iam_api_key.snapshot_scheduler.secret_key
    SCW_DEFAULT_PROJECT_ID      = var.project_id
    SCW_DEFAULT_ORGANIZATION_ID = var.organization_id
    SCW_DEFAULT_REGION          = var.region
    SCW_DEFAULT_ZONE            = "${var.region}-1"
    VOLUME_ID                   = local.volume_id_short
    RETENTION_COUNT             = tostring(var.retention_count)
    SNAPSHOT_SCRIPT             = local.snapshot_script
  }
}
