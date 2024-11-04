variable "location" {
  description = "The location name"
  type        = string
}

variable "node_count" {
  description = "The number of AKS nodes"
  type        = number
}

variable "environment" {
  description = "The environment (dev or prod)"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "kubernetes_cluster_name" {
  type        = string
  default     = "myAks"
  description = "The name of the Kubernetes cluster."
}
