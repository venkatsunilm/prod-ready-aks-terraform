variable "environment" {
  description = "The environment (dev or prod)"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to the Kubernetes config file"
  type        = string
  default     = "/home/runner/.kube/config" # Default value
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "aks_resource_group" {
  description = "The name of the AKS resource group"
  type        = string
}
