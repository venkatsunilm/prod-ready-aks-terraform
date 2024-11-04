resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  #   kubernetes_version  = "1.26.3"

  default_node_pool {
    name       = local.node_pool_name
    node_count = var.node_count
    vm_size    = local.vm_size
    # os_disk_size_gb = 30
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      upgrade_settings
    ]
  }

  identity {
    type = local.type
  }

  tags = {
    environment = var.environment
  }


}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry#example-usage-attaching-a-container-registry-to-a-kubernetes-cluster
# resource "azurerm_role_assignment" "attach_acr_aks" {
#   # principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
#   principal_id                     = azurerm_kubernetes_cluster.aks.identity[0].principal_id
#   role_definition_name             = "AcrPull"
#   scope                            = var.acr_registry_id
#   skip_service_principal_aad_check = true
# }

