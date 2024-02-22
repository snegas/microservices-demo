locals {
  environment_base = {
    dev   = "Development"
    stage = "Staging"
    prod  = "Production"
  }

  is_shared = var.type == "shared" ? 1 : 0
  env       = local.environment_base[terraform.workspace]

  prefix = "${terraform.workspace}-${var.type}-${var.prefix}"

  base_domain = terraform.workspace == "prod" ? var.base_domain : "${terraform.workspace}.${var.base_domain}"
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
  region = "nyc3"
}

resource "digitalocean_domain" "default" {
  count = local.is_shared
  name  = local.base_domain
}

resource "digitalocean_project_resources" "environment" {
  count   = local.is_shared
  project = digitalocean_project.environment[0].id
  resources = [
    digitalocean_domain.default[0].urn
  ]
}
