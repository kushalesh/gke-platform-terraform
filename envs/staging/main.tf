locals {
  env         = "staging"
  name_prefix = "platform-${local.env}"
  labels      = { env = local.env, managed = "terraform" }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source       = "../../modules/network"
  project_id   = var.project_id
  region       = var.region
  name_prefix  = local.name_prefix
  subnet_cidr  = "10.30.0.0/20"
  pods_cidr    = "10.40.0.0/14"
  services_cidr = "10.44.0.0/20"
  master_cidr  = "172.16.0.16/28"
  labels       = local.labels
}

module "cluster" {
  source                      = "../../modules/gke-cluster"
  project_id                  = var.project_id
  region                      = var.region
  cluster_name                = "${local.name_prefix}-gke"
  network                     = module.network.network_id
  subnetwork                  = module.network.subnetwork_id
  pods_range_name             = module.network.pods_range_name
  services_range_name         = module.network.services_range_name
  enable_private_endpoint     = true
  enable_binary_authorization = true
  master_authorized_networks  = [{ cidr_block = "10.0.0.0/8", display_name = "corp" }]
  labels                      = local.labels
}

module "workload_pool" {
  source          = "../../modules/node-pool"
  project_id      = var.project_id
  cluster_name    = module.cluster.cluster_name
  location        = var.region
  node_pool_name  = "workload"
  service_account = module.cluster.node_service_account_email
  machine_type    = "n2-standard-8"
  min_node_count  = 2
  max_node_count  = 20
  labels          = merge(local.labels, { pool = "workload" })
}
