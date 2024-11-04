# Get the managed identity (or service principal) for AKS
export AKS_IDENTITY_PRINCIPAL=$(az aks show --name $AKS_CLUSTER_NAME --resource-group $AKS_RESOURCE_GROUP --query "identityProfile.kubeletidentity.objectId" --output tsv)

# Check if AcrPull role is assigned to the AKS managed identity
ACR_SCOPE="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$AKS_RESOURCE_GROUP/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME"
ROLE_ASSIGNED=$(az role assignment list --assignee $AKS_IDENTITY_PRINCIPAL --scope $ACR_SCOPE --query "[?roleDefinitionName=='AcrPull'].roleDefinitionName" --output tsv)

if [ -n "$ROLE_ASSIGNED" ]; then
  echo "true"
else
  echo "false"
fi

az role assignment create --assignee $AKS_IDENTITY_PRINCIPAL --role "AcrPull" --scope "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$AKS_RESOURCE_GROUP/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME"

if [ -n "$ROLE_ASSIGNED" ]; then
  echo "true"
else
  echo "false"
fi