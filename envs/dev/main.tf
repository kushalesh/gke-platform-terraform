locals {
  env         = "dev"
  name_prefix = "platform-${local.env}"
  labels = {
    env     = local.env
    managed = "terraform"
    owner   = "platform-team"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source = "../../modules/network"

  project_id   = var.project_id
  region       = var.region
  name_prefix  = local.name_prefix
  subnet_cidr  = "10.10.0.0/20"
  pods_cidr    = "10.20.0.0/14"
  services_cidr = "10.24.0.0/20"
  master_cidr  = "172.16.0.0/28"
  labels       = local.labels
}

module "cluster" {
  source = "../../modules/gke-cluster"

  project_id          = var.project_id
  region              = var.region
  cluster_name        = "${local.name_prefix}-gke"
  network             = module.network.network_id
  subnetwork          = module.network.subnetwork_id
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name

  enable_private_endpoint     = false # dev: allow API access from authorized networks
  enable_binary_authorization = false # dev: easier iteration
  master_authorized_networks = [
    { cidr_block = "0.0.0.0/0", display_name = "anywhere-dev-only" },
  ]
  labels = local.labels
}

module "system_pool" {
  source = "../../modules/node-pool"

  project_id      = var.project_id
  cluster_name    = module.cluster.cluster_name
  location        = var.region
  node_pool_name  = "system"
  service_account = module.cluster.node_service_account_email

  machine_type    = "e2-standard-4"
  min_node_count  = 1
  max_node_count  = 3
  taints = [{
    key    = "components.gke.io/gke-managed-components"
    value  = "true"
    effect = "NO_SCHEDULE"
  }]
  labels = merge(local.labels, { pool = "system" })
}

module "workload_pool" {
  source = "../../modules/node-pool"

  project_id      = var.project_id
  cluster_name    = module.cluster.cluster_name
  location        = var.region
  node_pool_name  = "workload-spot"
  service_account = module.cluster.node_service_account_email

  machine_type   = "e2-standard-4"
  min_node_count = 1
  max_node_count = 10
  spot           = true # cost optimization for dev
  labels         = merge(local.labels, { pool = "workload" })
}
