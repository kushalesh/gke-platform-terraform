# Network Module

Provisions the foundational networking for a private GKE cluster:

- Custom-mode VPC (regional routing)
- Subnetwork with secondary ranges for **pods** and **services** (alias IPs)
- Cloud Router + Cloud NAT for egress from private nodes
- VPC Flow Logs (sampled)
- Firewall rule allowing GKE control plane → node webhook ports (8443/9443/10250/15017)

Pair with the `gke-cluster` and `node-pool` modules.

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
| [google_compute_firewall.master_to_nodes_webhooks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix applied to all resource names (e.g. environment-team). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID where the network resources will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for the subnetwork. | `string` | n/a | yes |
| <a name="input_enable_flow_logs"></a> [enable\_flow\_logs](#input\_enable\_flow\_logs) | Enable VPC flow logs on the subnetwork. | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to network resources. | `map(string)` | `{}` | no |
| <a name="input_master_cidr"></a> [master\_cidr](#input\_master\_cidr) | CIDR /28 for the GKE master endpoint (private cluster). | `string` | `"172.16.0.0/28"` | no |
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr) | Secondary CIDR for GKE pods (alias IP). | `string` | `"10.20.0.0/14"` | no |
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr) | Secondary CIDR for GKE services (alias IP). | `string` | `"10.24.0.0/20"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Primary CIDR for the GKE node subnetwork. | `string` | `"10.10.0.0/20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | VPC network ID. |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | VPC network name. |
| <a name="output_pods_range_name"></a> [pods\_range\_name](#output\_pods\_range\_name) | Secondary range name for pods. |
| <a name="output_services_range_name"></a> [services\_range\_name](#output\_services\_range\_name) | Secondary range name for services. |
| <a name="output_subnetwork_id"></a> [subnetwork\_id](#output\_subnetwork\_id) | Subnetwork ID for GKE nodes. |
| <a name="output_subnetwork_name"></a> [subnetwork\_name](#output\_subnetwork\_name) | Subnetwork name. |
<!-- END_TF_DOCS -->