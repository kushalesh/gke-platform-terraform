locals {
  env         = "prod"
  name_prefix = "platform-${local.env}"
  labels      = { env = local.env, managed = "terraform", criticality = "tier1" }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud KMS key for application-layer secrets encryption (etcd).
resource "google_kms_key_ring" "gke" {
  project  = var.project_id
  name     = "gke-${local.env}"
  location = var.region
}

resource "google_kms_crypto_key" "gke_secrets" {
  name            = "gke-secrets"
  key_ring        = google_kms_key_ring.gke.id
  rotation_period = "7776000s" # 90 days
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant the Container Engine Robot SA permission to use the key.
data "google_project" "this" {
  project_id = var.project_id
}

resource "google_kms_crypto_key_iam_member" "gke_sa" {
  crypto_key_id = google_kms_crypto_key.gke_secrets.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.this.number}@container-engine-robot.iam.gserviceaccount.com"
}

module "network" {
  source       = "../../modules/network"
  project_id   = var.project_id
  region       = var.region
  name_prefix  = local.name_prefix
  subnet_cidr  = "10.50.0.0/20"
  pods_cidr    = "10.60.0.0/14"
  services_cidr = "10.64.0.0/20"
  master_cidr  = "172.16.0.32/28"
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
  release_channel             = "STABLE"
  kms_key_name                = google_kms_crypto_key.gke_secrets.id
  master_authorized_networks  = [{ cidr_block = "10.0.0.0/8", display_name = "corp" }]
  labels                      = local.labels
}

module "system_pool" {
  source          = "../../modules/node-pool"
  project_id      = var.project_id
  cluster_name    = module.cluster.cluster_name
  location        = var.region
  node_pool_name  = "system"
  service_account = module.cluster.node_service_account_email
  machine_type    = "n2-standard-4"
  min_node_count  = 3
  max_node_count  = 6
  taints = [{
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }]
  labels = merge(local.labels, { pool = "system" })
}

module "workload_pool" {
  source          = "../../modules/node-pool"
  project_id      = var.project_id
  cluster_name    = module.cluster.cluster_name
  location        = var.region
  node_pool_name  = "workload"
  service_account = module.cluster.node_service_account_email
  machine_type    = "n2-standard-16"
  min_node_count  = 3
  max_node_count  = 50
  labels          = merge(local.labels, { pool = "workload" })
}
