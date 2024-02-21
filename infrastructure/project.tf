locals {
  environment_base = {
    dev = "Development"
    stage = "Staging"
    prod = "Production"
  }

  is_shared = var.type == "shared" ? 1 : 0
  env = local.environment_base[terraform.workspace]

  prefix = "${terraform.workspace}-${var.prefix}"
}

resource "digitalocean_project" "environment" {
  count       = local.is_shared
  name        = "${local.prefix}-env"
  description = "A project to represent ${local.env} resources."
  purpose     = "Web Application"
  environment = local.env
}