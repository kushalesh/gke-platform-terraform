# 🛡️ gke-platform-terraform

[![terraform](https://img.shields.io/badge/terraform-≥1.5-623CE4?logo=terraform)](https://www.terraform.io/)
[![GKE](https://img.shields.io/badge/GKE-1.30-326CE5?logo=kubernetes)](https://cloud.google.com/kubernetes-engine)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/kushalesh/gke-platform-terraform/actions/workflows/terraform.yml/badge.svg)](./.github/workflows/terraform.yml)

> Production-grade, opinionated **Terraform modules** to provision a private, secure, observable **GKE platform** on GCP — built with senior platform engineering best practices.

---

## ✨ Highlights

- 🔒 **Security-first**: private cluster, Workload Identity, Shielded Nodes, Binary Authorization, dedicated least-privilege node SA, optional Cloud KMS etcd encryption
- 🌐 **Modern networking**: VPC-native, alias IPs, Cloud NAT egress, VPC flow logs, **Dataplane V2 (Cilium / eBPF)**
- 📈 **Observability**: managed Prometheus, full control plane logging/monitoring, VPC flow logs
- ♻️ **Operationally sound**: regional HA, surge upgrades, weekly maintenance window, auto-repair, auto-upgrade, VPA
- 💰 **Cost-aware**: Spot pool support, multiple right-sized pools, autoscaling per pool
- ✅ **Quality gates**: pre-commit + `terraform fmt/validate/tflint/tfsec/checkov` + Terratest in CI
- 📚 **Multi-env**: ready-made `dev`, `staging`, `prod` overlays

---

## 🏗 Repository Layout

```
.
├── modules/
│   ├── network/        # VPC, subnet, Cloud NAT, firewall, flow logs
│   ├── gke-cluster/    # Private regional GKE cluster + node SA + IAM
│   └── node-pool/      # Reusable node pool with autoscaling, taints, spot
├── envs/
│   ├── dev/            # Public endpoint, BinAuthz off, spot pool
│   ├── staging/        # Private endpoint, BinAuthz on
│   └── prod/           # Private endpoint, KMS, STABLE channel, big pools
├── examples/basic/
├── tests/              # Terratest validating examples
├── .github/workflows/  # CI: fmt, validate, tflint, tfsec, checkov, docs
└── Makefile            # Day-to-day workflow shortcuts
```

## 🚀 Quick Start

```bash
# 1. Bootstrap auth (once)
gcloud auth application-default login

# 2. Set your project & region
cp envs/dev/terraform.tfvars.example envs/dev/terraform.tfvars
# edit envs/dev/terraform.tfvars

# 3. Plan
make plan ENV=dev

# 4. Apply
make apply ENV=dev
```

## 🔐 Security Posture (Defaults)

| Control | Setting |
|---|---|
| Private nodes | ✅ |
| Private endpoint (prod/staging) | ✅ |
| Workload Identity | ✅ |
| Shielded nodes (Secure Boot + IM) | ✅ |
| Binary Authorization (prod/staging) | ✅ enforce |
| Legacy ABAC | ❌ disabled |
| Default Compute SA on nodes | ❌ removed (dedicated SA) |
| etcd encryption (prod) | ✅ Cloud KMS |
| VPC flow logs | ✅ sampled |
| OAuth scopes | `cloud-platform` (least-priv enforced via SA) |

## 🧪 Testing

```bash
# Local validation
make validate ENV=dev
make lint
make security-scan

# Terratest (no apply)
cd tests && go test -v -timeout 30m

# Full integration (creates real resources!)
APPLY=true go test -v -timeout 60m
```

## 📐 Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed diagrams and design decisions.

## 📜 License

MIT — see [LICENSE](LICENSE).

---
**Author:** Kushalesh — Senior GKE Platform Engineer
