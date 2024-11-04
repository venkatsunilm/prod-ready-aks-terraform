resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = local.account_tier
  account_replication_type = local.account_replication_type

  tags = {
    environment = var.environment
  }

  timeouts {
    create = "30m" # Set a 30-minute timeout for storage account creation
  }

}
