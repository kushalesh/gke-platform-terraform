# Production-grade private regional GKE cluster.
# Defaults align with CIS GKE Benchmark + Google security best practices:
#   - Private nodes & private endpoint
#   - Workload Identity enabled
#   - Shielded nodes (Secure Boot + integrity monitoring)
#   - Dataplane V2 (Cilium) for NetworkPolicy + observability
#   - Binary Authorization
#   - Application-layer secrets encryption via Cloud KMS (optional)
#   - VPC-native, alias IPs only
#   - Default node pool removed (managed via separate node-pool module)

resource "google_container_cluster" "this" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  # Remove the default node pool so we manage pools explicitly via the module.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  min_master_version = var.kubernetes_version

  release_channel {
    channel = var.release_channel
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Dataplane V2 (Cilium) — disables kube-proxy and provides eBPF observability.
  datapath_provider = var.enable_dataplane_v2 ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"
  network_policy {
    enabled = !var.enable_dataplane_v2 # mutually exclusive with Dataplane V2 NP
  }

  # Workload Identity — pods authenticate to GCP via KSA → GSA binding.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_cidr
    master_global_access_config {
      enabled = true
    }
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  binary_authorization {
    evaluation_mode = var.enable_binary_authorization ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  dynamic "database_encryption" {
    for_each = var.kms_key_name == null ? [] : [1]
    content {
      state    = "ENCRYPTED"
      key_name = var.kms_key_name
    }
  }

  # Disable legacy / insecure features.
  enable_legacy_abac       = false
  enable_shielded_nodes    = true
  enable_intranode_visibility = true

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = var.enable_dataplane_v2
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
    dns_cache_config {
      enabled = true
    }
    config_connector_config {
      enabled = false
    }
  }

  cluster_autoscaling {
    enabled = false # node-pool module handles per-pool autoscaling
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_window_start
      end_time   = var.maintenance_window_end
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
      "APISERVER",
      "CONTROLLER_MANAGER",
      "SCHEDULER",
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "APISERVER",
      "CONTROLLER_MANAGER",
      "SCHEDULER",
      "STORAGE",
      "HPA",
      "POD",
      "DAEMONSET",
      "DEPLOYMENT",
      "STATEFULSET",
    ]
    managed_prometheus {
      enabled = true
    }
  }

  resource_labels = var.labels

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config,
    ]
  }
}
