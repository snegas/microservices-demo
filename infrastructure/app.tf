locals {
  is_app = var.type == "app"
  is_redis = var.type == "app" && var.redis
  is_external = var.type == "app" && var.external

  all_redis_settings = {
    dev = {
      size       = "db-s-1vcpu-1gb"
      node_count = 1
    }
    stage = {
      size       = "db-s-1vcpu-2gb"
      node_count = 2
    }
    prod = {
      size       = "db-s-1vcpu-2gb"
      node_count = 2
    }
  }

  current_redis_settings = local.all_redis_settings[terraform.workspace]

  app_domain_name = local.is_external ? trimprefix(element([for i in data.digitalocean_project.shared[0].resources : i if startswith(i, "do:domain:")], 0), "do:domain:") : null
}

data "digitalocean_vpc" "shared" {
  count = local.is_app ? 1 : 0
  name  = "${terraform.workspace}-shared-infra-vpc"
}

data "digitalocean_project" "shared" {
  count = local.is_app ? 1 : 0
  name  = "${terraform.workspace}-shared-infra"
}

resource "digitalocean_database_cluster" "redis" {
  count                = local.is_redis ? 1 : 0
  name                 = "${local.prefix}-redis"
  engine               = "redis"
  version              = "7"
  size                 = local.current_redis_settings["size"]
  region               = var.region
  node_count           = local.current_redis_settings["node_count"]
  private_network_uuid = data.digitalocean_vpc.shared[0].id
  project_id           = data.digitalocean_project.shared[0].id
}

resource "digitalocean_database_firewall" "redis" {
  count      = local.is_redis ? 1 : 0
  cluster_id = digitalocean_database_cluster.redis[0].id

  rule {
    type  = "ip_addr"
    value = data.digitalocean_vpc.shared[0].ip_range
  }
}

data "digitalocean_domain" "external" {
  count = local.is_external ? 1 : 0
  name  = local.app_domain_name
}

resource "digitalocean_record" "external" {
  count  = local.is_external ? 1 : 0
  domain = data.digitalocean_domain.external[0].id
  type   = "A"
  name   = "@"
  value  = digitalocean_loadbalancer.external[0].ip
}

resource "digitalocean_certificate" "external" {
  count  = local.is_external ? 1 : 0

  name    = "${local.prefix}-cert"
  type    = "lets_encrypt"
  domains = [local.app_domain_name]
}

resource "digitalocean_loadbalancer" "external" {
  count  = local.is_external ? 1 : 0
  name   = "${local.prefix}-lb"
  region = var.region

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.external[0].name
  }

  project_id = data.digitalocean_project.shared[0].id
  vpc_uuid   = data.digitalocean_vpc.shared[0].id
}