variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "location" {
  description = "The location/region where the AKS cluster will be deployed"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}
