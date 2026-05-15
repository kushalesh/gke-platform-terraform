variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region for the cluster (regional cluster for HA)."
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Minimum Kubernetes version for the control plane (e.g. 1.30)."
  type        = string
  default     = "1.30"
}

variable "release_channel" {
  description = "GKE release channel: RAPID, REGULAR, STABLE."
  type        = string
  default     = "REGULAR"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be RAPID, REGULAR or STABLE."
  }
}

variable "network" {
  description = "VPC self-link or name."
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self-link or name."
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods."
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services."
  type        = string
}

variable "master_cidr" {
  description = "CIDR /28 for the master endpoint."
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of authorized CIDRs that can reach the public endpoint (empty = no public access)."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_private_endpoint" {
  description = "If true, the master endpoint is only reachable privately."
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enforce Binary Authorization on the cluster."
  type        = bool
  default     = true
}

variable "kms_key_name" {
  description = "Optional Cloud KMS key for application-layer secrets encryption (etcd)."
  type        = string
  default     = null
}

variable "enable_dataplane_v2" {
  description = "Enable GKE Dataplane V2 (Cilium-based)."
  type        = bool
  default     = true
}

variable "maintenance_window_start" {
  description = "RFC3339 start time of recurring maintenance window."
  type        = string
  default     = "2026-01-01T03:00:00Z"
}

variable "maintenance_window_end" {
  description = "RFC3339 end time of recurring maintenance window."
  type        = string
  default     = "2026-01-01T07:00:00Z"
}

variable "labels" {
  description = "Labels applied to the cluster."
  type        = map(string)
  default     = {}
}
