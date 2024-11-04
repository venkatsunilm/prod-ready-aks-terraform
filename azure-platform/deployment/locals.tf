locals {
  resource_group_name = "rg-${var.environment}"
  location            = var.location
  environment         = var.environment

  # AKS
  cluster_name = "aks-${var.environment}"
  dns_prefix   = "${var.environment}-aks"

  # Networking
  vnet_name   = "vnet-${var.environment}"
  subnet_name = "subnet-${var.environment}"

  # storage
  # storage_account_name = "sa${var.environment}${random_string.storage_suffix.result}"

  # ACR
  registry_name           = "venkatsunilm${var.environment}"
  acr_resource_group_name = "rg-acr-${var.environment}"

}
