data "github_repository" "environment" {
  count     = local.is_shared
  full_name = var.repository
}

resource "github_actions_environment_secret" "environment" {
  count             = local.is_shared
  repository        = data.github_repository.environment[0].name
  environment       = terraform.workspace
  secret_name       = "KUBECONFIG"
  encrypted_value   = base64encode(digitalocean_kubernetes_cluster.environment[0].kube_config[0].raw_config)
}