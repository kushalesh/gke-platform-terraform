# Dedicated service account for GKE nodes (least privilege; not the default Compute SA).
resource "google_service_account" "node_sa" {
  project      = var.project_id
  account_id   = "${var.cluster_name}-nodes"
  display_name = "GKE node SA for ${var.cluster_name}"
}

# Minimum roles needed by nodes for logging, monitoring and pulling images.
locals {
  node_sa_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
  ]
}

resource "google_project_iam_member" "node_sa" {
  for_each = toset(local.node_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.node_sa.email}"
}
