output "module_path" {
  value = path.module
}

output "env_helm_values" {
  value = helm_release.data-upload-app.values
}

output "aks_cluster_kube_config" {
  value = data.azurerm_kubernetes_cluster.aks.kube_config
}

output "aks_cluster_kube_admin_config" {
  value = data.azurerm_kubernetes_cluster.aks.kube_admin_config
}
