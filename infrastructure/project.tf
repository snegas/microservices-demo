locals {
  environment_base = {
    dev   = "Development"
    stage = "Staging"
    prod  = "Production"
  }

  is_shared = var.type == "shared" ? 1 : 0
  env       = local.environment_base[terraform.workspace]

  prefix = "${terraform.workspace}-${var.type}-${var.prefix}"

  is_not_dev = local.env != "dev"

  base_domain = terraform.workspace == "prod" ? var.base_domain : "${terraform.workspace}.${var.base_domain}"

  nodes = {
    dev = {
      min = 1
      max = 3
    }

    stage = {
      min = 2
      max = 5
    }

    prod = {
      min = 2
      max = 5
    }
  }
}

resource "digitalocean_project" "environment" {
  count       = local.is_shared
  name        = local.prefix
  description = "A project to represent ${local.env} resources."
  purpose     = "Web Application"
  environment = local.env
}

resource "digitalocean_vpc" "default" {
  count  = local.is_shared
  name   = "${local.prefix}-vpc"
  region = var.region
}

resource "digitalocean_domain" "default" {
  count = local.is_shared
  name  = local.base_domain
}

resource "digitalocean_project_resources" "environment" {
  count   = local.is_shared
  project = digitalocean_project.environment[0].id
  resources = [
    digitalocean_domain.default[0].urn,
    digitalocean_kubernetes_cluster.environment[0].urn
  ]
}

data "digitalocean_kubernetes_versions" "environment" {
  count          = local.is_shared
  version_prefix = "1.29."
}

resource "digitalocean_kubernetes_cluster" "environment" {
  count        = local.is_shared
  name         = "${local.prefix}-cluster"
  region       = var.region
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.environment[0].latest_version
  vpc_uuid     = digitalocean_vpc.default[0].id
  ha           = local.is_not_dev

  maintenance_policy {
    start_time = "02:00"
    day        = "sunday"
  }

  node_pool {
    name       = "${local.prefix}-nodes-pool"
    size       = "s-2vcpu-2gb"
    auto_scale = true
    min_nodes  = local.nodes[terraform.workspace]["min"]
    max_nodes  = local.nodes[terraform.workspace]["max"]
  }
}