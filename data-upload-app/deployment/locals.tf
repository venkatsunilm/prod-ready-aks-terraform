locals {
  resource_group_name = "rg-${var.environment}"
  aks_cluster_name    = "aks-${var.environment}"
  location            = var.location
  environment         = var.environment
}
