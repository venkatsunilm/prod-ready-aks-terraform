# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release

// Retrieve AKS cluster information
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group
}

resource "helm_release" "data-upload-app" {
  name  = local.app_name
  chart = "${path.module}/app-chart" # Adjust path to app-chart

  values = [
    file("${path.module}/app-chart/${var.environment}-values.yaml") # Adjust for environment-specific values
  ]

  provider = helm.aks
}
