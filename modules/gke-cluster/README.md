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
