# GKE Cluster Module

Provisions a **production-grade private regional GKE cluster** with the security and reliability defaults expected at senior platform engineering bar:

| Feature | Default |
|---|---|
| Topology | Regional (HA control plane), VPC-native, alias IPs |
| Private cluster | Private nodes ✓, private endpoint ✓ (configurable) |
| Workload Identity | Enabled (`PROJECT.svc.id.goog`) |
| Shielded Nodes | Enabled (Secure Boot + integrity monitoring) |
| Dataplane | V2 (Cilium / eBPF) |
| Network Policy | Provided by Dataplane V2 |
| Binary Authorization | `PROJECT_SINGLETON_POLICY_ENFORCE` |
| etcd encryption | Cloud KMS (optional) |
| Logging | System + workloads + control plane components |
| Monitoring | Managed Prometheus + GKE control plane metrics |
| Maintenance | Weekly window (Sat/Sun, configurable) |
| Default node pool | Removed (manage via `node-pool` module) |
| Node SA | Dedicated, least-privilege (no default Compute SA) |
| VPA | Enabled |

## Usage

```hcl
module "cluster" {
  source = "../../modules/gke-cluster"

  project_id           = "my-project"
  region               = "europe-west1"
  cluster_name         = "platform-prod"
  network              = module.network.network_id
  subnetwork           = module.network.subnetwork_id
  pods_range_name      = module.network.pods_range_name
  services_range_name  = module.network.services_range_name
  kms_key_name         = google_kms_crypto_key.gke.id

  master_authorized_networks = [
    { cidr_block = "10.0.0.0/8", display_name = "corp" }
  ]
}
```

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
| [google_container_cluster.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_project_iam_member.node_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.node_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE cluster. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | VPC self-link or name. | `string` | n/a | yes |
| <a name="input_pods_range_name"></a> [pods\_range\_name](#input\_pods\_range\_name) | Secondary range name for pods. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for the cluster (regional cluster for HA). | `string` | n/a | yes |
| <a name="input_services_range_name"></a> [services\_range\_name](#input\_services\_range\_name) | Secondary range name for services. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Subnetwork self-link or name. | `string` | n/a | yes |
| <a name="input_enable_binary_authorization"></a> [enable\_binary\_authorization](#input\_enable\_binary\_authorization) | Enforce Binary Authorization on the cluster. | `bool` | `true` | no |
| <a name="input_enable_dataplane_v2"></a> [enable\_dataplane\_v2](#input\_enable\_dataplane\_v2) | Enable GKE Dataplane V2 (Cilium-based). | `bool` | `true` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | If true, the master endpoint is only reachable privately. | `bool` | `true` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Optional Cloud KMS key for application-layer secrets encryption (etcd). | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Minimum Kubernetes version for the control plane (e.g. 1.30). | `string` | `"1.30"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the cluster. | `map(string)` | `{}` | no |
| <a name="input_maintenance_window_end"></a> [maintenance\_window\_end](#input\_maintenance\_window\_end) | RFC3339 end time of recurring maintenance window. | `string` | `"2026-01-01T07:00:00Z"` | no |
| <a name="input_maintenance_window_start"></a> [maintenance\_window\_start](#input\_maintenance\_window\_start) | RFC3339 start time of recurring maintenance window. | `string` | `"2026-01-01T03:00:00Z"` | no |
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | List of authorized CIDRs that can reach the public endpoint (empty = no public access). | <pre>list(object({<br/>    cidr_block   = string<br/>    display_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_master_cidr"></a> [master\_cidr](#input\_master\_cidr) | CIDR /28 for the master endpoint. | `string` | `"172.16.0.0/28"` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | GKE release channel: RAPID, REGULAR, STABLE. | `string` | `"REGULAR"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | Cluster CA certificate (base64 encoded). |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Fully qualified cluster ID. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | GKE master endpoint (private). |
| <a name="output_node_service_account_email"></a> [node\_service\_account\_email](#output\_node\_service\_account\_email) | Email of the dedicated SA for GKE node pools. |
| <a name="output_workload_identity_pool"></a> [workload\_identity\_pool](#output\_workload\_identity\_pool) | Workload Identity pool for the cluster. |
<!-- END_TF_DOCS -->