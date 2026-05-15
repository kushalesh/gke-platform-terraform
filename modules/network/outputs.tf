output "network_id" {
  description = "VPC network ID."
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "VPC network name."
  value       = google_compute_network.vpc.name
}

output "subnetwork_id" {
  description = "Subnetwork ID for GKE nodes."
  value       = google_compute_subnetwork.gke.id
}

output "subnetwork_name" {
  description = "Subnetwork name."
  value       = google_compute_subnetwork.gke.name
}

output "pods_range_name" {
  description = "Secondary range name for pods."
  value       = "pods"
}

output "services_range_name" {
  description = "Secondary range name for services."
  value       = "services"
}
