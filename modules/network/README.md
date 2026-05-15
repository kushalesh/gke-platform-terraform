# Network Module

Provisions the foundational networking for a private GKE cluster:

- Custom-mode VPC (regional routing)
- Subnetwork with secondary ranges for **pods** and **services** (alias IPs)
- Cloud Router + Cloud NAT for egress from private nodes
- VPC Flow Logs (sampled)
- Firewall rule allowing GKE control plane → node webhook ports (8443/9443/10250/15017)

Pair with the `gke-cluster` and `node-pool` modules.
