# Architecture

## High-Level Diagram

```mermaid
flowchart TB
  subgraph GCP_Project["GCP Project"]
    subgraph VPC["VPC (custom mode, regional)"]
      subgraph Subnet["Subnet (10.10.0.0/20)"]
        Pods["Pods range<br/>10.20.0.0/14"]
        Svcs["Services range<br/>10.24.0.0/20"]
      end
      Router[Cloud Router] --> NAT[Cloud NAT]
    end

    subgraph GKE["GKE Cluster (Private, Regional)"]
      CP["Control Plane<br/>Private endpoint<br/>172.16.0.0/28"]
      SysPool["System node pool<br/>(tainted)"]
      WorkPool["Workload node pool<br/>(autoscaling)"]
      SpotPool["Spot node pool<br/>(cost-optimized)"]
    end

    KMS[Cloud KMS<br/>etcd encryption]
    SA[Dedicated Node SA<br/>least privilege]
    BinAuthz[Binary Authorization]
    Logs[Cloud Logging + Monitoring<br/>+ Managed Prometheus]
  end

  Subnet -. alias IPs .-> SysPool
  Subnet -. alias IPs .-> WorkPool
  Subnet -. alias IPs .-> SpotPool
  CP -. encrypts secrets .-> KMS
  SysPool & WorkPool & SpotPool -. uses .-> SA
  GKE -. enforces .-> BinAuthz
  GKE -. ships telemetry .-> Logs
  WorkPool -. egress via .-> NAT
```

## Design Decisions

### Why Regional Clusters?
- HA control plane across 3 zones → no single-zone control plane outage
- Higher SLA (99.95% vs 99.5% zonal)
- Slight cost increase justified for production

### Why Dataplane V2?
- eBPF-based — better performance than iptables kube-proxy
- Built-in NetworkPolicy enforcement (no Calico add-on)
- Hubble-style observability
- Removes need for kube-proxy DaemonSet

### Why Dedicated Node SA?
- Default Compute SA has Editor on the project (security anti-pattern)
- Custom SA with only the 5 roles GKE actually needs
- Easier to audit and rotate

### Why Workload Identity?
- Pods can authenticate to GCP **without secret keys** mounted
- KSA → GSA binding via annotation
- Eliminates the entire class of "leaked SA key" incidents

### Why Multi-Pool Architecture?
- **System pool** (tainted) — guarantees control plane add-ons have capacity
- **Workload pool** — application workloads, scales aggressively
- **Spot pool** — batch / fault-tolerant workloads at 60-80% cost savings

### Why Per-Env Separate State?
- Blast radius isolation
- Different velocity (dev iterates faster than prod)
- Different security posture (BinAuthz off in dev for speed)

## Future Work

- [ ] Add `bigtable` / `spanner` companion modules
- [ ] Add Anthos Config Management bootstrap
- [ ] Add Multi-Cluster Ingress (MCI) example
- [ ] Add Backup for GKE configuration
