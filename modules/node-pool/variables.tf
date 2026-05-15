variable "project_id" { type = string }
variable "cluster_name" { type = string }
variable "location" {
  type        = string
  description = "Region (regional cluster) or zone."
}
variable "node_pool_name" { type = string }
variable "service_account" {
  type        = string
  description = "Email of the GKE node SA created by the cluster module."
}
variable "machine_type" {
  type    = string
  default = "e2-standard-4"
}
variable "disk_size_gb" {
  type    = number
  default = 100
}
variable "disk_type" {
  type    = string
  default = "pd-balanced"
}
variable "image_type" {
  type    = string
  default = "COS_CONTAINERD"
}
variable "min_node_count" {
  type    = number
  default = 1
}
variable "max_node_count" {
  type    = number
  default = 5
}
variable "spot" {
  type        = bool
  default     = false
  description = "Use Spot VMs (huge cost savings, may be preempted)."
}
variable "taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "tags" {
  type    = list(string)
  default = []
}
variable "max_surge" {
  type    = number
  default = 1
}
variable "max_unavailable" {
  type    = number
  default = 0
}
