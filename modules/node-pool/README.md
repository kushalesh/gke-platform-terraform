<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_node_pool.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region (regional cluster) or zone. | `string` | n/a | yes |
| <a name="input_node_pool_name"></a> [node\_pool\_name](#input\_node\_pool\_name) | n/a | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Email of the GKE node SA created by the cluster module. | `string` | n/a | yes |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | n/a | `number` | `100` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | n/a | `string` | `"pd-balanced"` | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | n/a | `string` | `"COS_CONTAINERD"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | n/a | `string` | `"e2-standard-4"` | no |
| <a name="input_max_node_count"></a> [max\_node\_count](#input\_max\_node\_count) | n/a | `number` | `5` | no |
| <a name="input_max_surge"></a> [max\_surge](#input\_max\_surge) | n/a | `number` | `1` | no |
| <a name="input_max_unavailable"></a> [max\_unavailable](#input\_max\_unavailable) | n/a | `number` | `0` | no |
| <a name="input_min_node_count"></a> [min\_node\_count](#input\_min\_node\_count) | n/a | `number` | `1` | no |
| <a name="input_spot"></a> [spot](#input\_spot) | Use Spot VMs (huge cost savings, may be preempted). | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `list(string)` | `[]` | no |
| <a name="input_taints"></a> [taints](#input\_taints) | n/a | <pre>list(object({<br/>    key    = string<br/>    value  = string<br/>    effect = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_pool_id"></a> [node\_pool\_id](#output\_node\_pool\_id) | n/a |
| <a name="output_node_pool_name"></a> [node\_pool\_name](#output\_node\_pool\_name) | n/a |
<!-- END_TF_DOCS -->