locals {
  kubeconfig = !local.is_app ? templatefile("kubeconfig.tftpl", {
    ca_certificate = base64decode(digitalocean_kubernetes_cluster.environment[0].kube_config[0].cluster_ca_certificate)
    host           = digitalocean_kubernetes_cluster.environment[0].endpoint
    token          = digitalocean_kubernetes_cluster.environment[0].kube_config[0].token
  }) : null
}

resource "github_actions_environment_secret" "example_secret" {
    count             = local.is_shared
    repository        = var.repository
    environment       = terraform.workspace
    secret_name       = "KUBECONFIG"
    encrypted_value   = base64decode(local.kubeconfig)
}