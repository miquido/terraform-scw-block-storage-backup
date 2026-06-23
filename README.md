# scw-block-storage-backup <a href="https://miquido.com"><img align="right" src="https://cdn.miquido.dev/miquido-logo.png" width="150" /></a>

Terraform module for scheduled Scaleway block storage snapshots with configurable retention.

## Development

```bash
make init   # run once after cloning
make readme # regenerate README.md
make lint   # lint terraform code
```

## Usage

```hcl
module "block_storage_backup" {
  source = "git@gitlab.miquido.com:miquido/terraform/scw-block-storage-backup.git?ref=x.y.z"

  project         = "myproject"
  environment     = "production"
  project_id      = var.scaleway_project_id
  organization_id = var.scaleway_organization_id
  volume_id       = "fr-par-1/11111111-1111-1111-1111-111111111111"
  region          = "pl-waw"
  schedule        = "0 2 * * *"
  retention_count = 7
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [scaleway_iam_api_key.snapshot_scheduler](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_api_key) | resource |
| [scaleway_iam_application.snapshot_scheduler](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_application) | resource |
| [scaleway_iam_policy.snapshot_scheduler](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_policy) | resource |
| [scaleway_job_definition.snapshot](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/job_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | n/a | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"pl-waw"` | no |
| <a name="input_retention_count"></a> [retention\_count](#input\_retention\_count) | Number of snapshots to keep (oldest are deleted) | `number` | `7` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Cron expression (UTC) | `string` | `"0 2 * * *"` | no |
| <a name="input_volume_id"></a> [volume\_id](#input\_volume\_id) | ID of the block volume to snapshot | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## License

[MIT](LICENSE)
