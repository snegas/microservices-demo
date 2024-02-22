locals {
  is_app = var.type == "app"
  is_redis = var.type == "app" && var.redis

  all_redis_settings = {
    dev = {
      size       = "db-s-1vcpu-1gb"
      node_count = 1
    }
    stage = {
      size       = "db-s-1vcpu-1gb"
      node_count = 2
    }
    prod = {
      size       = "db-s-1vcpu-2gb"
      node_count = 2
    }
  }

  current_redis_settings = local.all_redis_settings[terraform.workspace]

  app_groups = compact(concat(
    is_redis ? [ digitalocean_database_cluster.redis[0].id ] : []
  ))
}

data "digitalocean_vpc" "shared" {
  count = local.is_app ? 1 : 0
  name  = "${terraform.workspace}-shared-infra-vpc"
}

resource "digitalocean_database_cluster" "redis" {
  count                = is_redis ? 1 : 0
  name                 = "${local.prefix}-redis"
  engine               = "redis"
  version              = "7"
  size                 = local.current_redis_settings["size"]
  region               = "nyc1"
  node_count           = local.current_redis_settings["node_count"]
  private_network_uuid = data.digitalocean_vpc.shared[0].id
}

data "digitalocean_project" "shared" {
  count = local.is_app ? 1 : 0
  name  = terraform.workspace
}

resource "digitalocean_project_resources" "app" {
  count     = local.is_app && length(local.app_groups) > 0 ? 1 : 0
  project   = data.digitalocean_project.shared[0].id
  resources = local.app_groups
}