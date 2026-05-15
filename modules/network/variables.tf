variable "project_id" {
  description = "GCP Project ID where the network resources will be created."
  type        = string
}

variable "region" {
  description = "GCP region for the subnetwork."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. environment-team)."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR for the GKE node subnetwork."
  type        = string
  default     = "10.10.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR for GKE pods (alias IP)."
  type        = string
  default     = "10.20.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR for GKE services (alias IP)."
  type        = string
  default     = "10.24.0.0/20"
}

variable "master_cidr" {
  description = "CIDR /28 for the GKE master endpoint (private cluster)."
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs on the subnetwork."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels applied to network resources."
  type        = map(string)
  default     = {}
}
