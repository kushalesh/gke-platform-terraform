output "cluster_id" {
  description = "Fully qualified cluster ID."
  value       = google_container_cluster.this.id
}

output "cluster_name" {
  description = "Cluster name."
  value       = google_container_cluster.this.name
}

output "endpoint" {
  description = "GKE master endpoint (private)."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "ca_certificate" {
  description = "Cluster CA certificate (base64 encoded)."
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "node_service_account_email" {
  description = "Email of the dedicated SA for GKE node pools."
  value       = google_service_account.node_sa.email
}

output "workload_identity_pool" {
  description = "Workload Identity pool for the cluster."
  value       = "${var.project_id}.svc.id.goog"
}
