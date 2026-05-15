# VPC, subnet, Cloud Router and NAT for a private GKE cluster.
# Designed for Workload Identity + Private Service Connect ready cluster.

locals {
  vpc_name    = "${var.name_prefix}-vpc"
  subnet_name = "${var.name_prefix}-subnet"
  router_name = "${var.name_prefix}-router"
  nat_name    = "${var.name_prefix}-nat"
}

resource "google_compute_network" "vpc" {
  project                         = var.project_id
  name                            = local.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = false
  description                     = "VPC for GKE platform (${var.name_prefix})."
}

resource "google_compute_subnetwork" "gke" {
  project                  = var.project_id
  name                     = local.subnet_name
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = local.router_name
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = local.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.gke.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Allow GKE master to reach webhooks on nodes (Cert-Manager, OPA, etc.)
resource "google_compute_firewall" "master_to_nodes_webhooks" {
  project   = var.project_id
  name      = "${var.name_prefix}-allow-master-webhooks"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [var.master_cidr]
  target_tags   = ["gke-${var.name_prefix}"]

  allow {
    protocol = "tcp"
    ports    = ["8443", "9443", "10250", "15017"]
  }
}
