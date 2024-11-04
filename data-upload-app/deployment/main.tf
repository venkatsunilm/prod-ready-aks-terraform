module "app" {
  source             = "../modules"
  environment        = local.environment
  aks_cluster_name   = local.aks_cluster_name
  aks_resource_group = local.resource_group_name
}
