# Minimal example wiring all three modules together.
# Run from this directory after setting GOOGLE_APPLICATION_CREDENTIALS or `gcloud auth application-default login`.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.30" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" { type = string }
variable "region" {
  type    = string
  default = "europe-west1"
}

module "network" {
  source       = "../../modules/network"
  project_id   = var.project_id
  region       = var.region
  name_prefix  = "example"
}

module "cluster" {
  source              = "../../modules/gke-cluster"
  project_id          = var.project_id
  region              = var.region
  cluster_name        = "example-gke"
  network             = module.network.network_id
  subnetwork          = module.network.subnetwork_id
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name
}

module "pool" {
  source          = "../../modules/node-pool"
  project_id      = var.project_id
  cluster_name    = module.cluster.cluster_name
  location        = var.region
  node_pool_name  = "default"
  service_account = module.cluster.node_service_account_email
}
