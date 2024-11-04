# APP_PATH="/mnt/c/Users/harit/Documents/Visual Studio 2022/DevOps/DevOps-Terraform-Sample/data-upload-app/src"

# Check if SUBSCRIPTION_ID is exported correctly
if [ -z "$ARM_SUBSCRIPTION_ID" ]; then
  echo "Error: ARM_SUBSCRIPTION_ID is not set. Please ensure it is exported in local_env_setup.sh."
  exit 1
fi

# 1. Navigate to the directory where the Dockerfile is located
echo "Navigating to $APP_PATH..."
cd "$APP_PATH" || { echo "Directory $APP_PATH not found. Exiting."; exit 1; }

# Debugging: Display Docker info before the build
docker info

# 2. Build the Docker image (latest tag is implied)
echo "Building Docker image: $DOCKER_IMAGE_NAME"
docker buildx build -t $DOCKER_IMAGE_NAME .

# 3. Run Docker container locally (optional, for local testing)
# echo "Running Docker container locally..."
# docker run -d -p $DOCKER_PORT:$DOCKER_PORT $DOCKER_IMAGE_NAME

# 4. Check if Resource Group for ACR already exists
az account show
echo "Checking if resource group $ACR_RESOURCE_GROUP exists..."
RG_EXISTS=$(az group exists --name $ACR_RESOURCE_GROUP | tr -d '[:space:]')

if [ "$RG_EXISTS" = "false" ]; then
  echo "Creating resource group $ACR_RESOURCE_GROUP in location $LOCATION..."
  az group create --name $ACR_RESOURCE_GROUP --location $LOCATION
else
  echo "Resource group $ACR_RESOURCE_GROUP already exists."
fi

# 5. Check if ACR already exists
echo "Checking if Azure Container Registry $ACR_NAME exists..."
ACR_EXISTS=$(az acr check-name --name $ACR_NAME --query "nameAvailable" | tr -d '[:space:]')

if [ "$ACR_EXISTS" = "false" ]; then
  echo "Azure Container Registry $ACR_NAME already exists."
else
  echo "Creating Azure Container Registry $ACR_NAME..."
  az acr create --resource-group $ACR_RESOURCE_GROUP --name $ACR_NAME --sku Basic --location $LOCATION
fi

# 6. Log in to ACR
echo "Logging into Azure Container Registry $ACR_NAME..."
az acr login --name $ACR_NAME

# 7. Tag the Docker image for ACR
echo "Tagging Docker image for ACR..."
docker tag $DOCKER_IMAGE_NAME $ACR_NAME.azurecr.io/$DOCKER_IMAGE_NAME:$DOCKER_TAG

# 8. Push the Docker image to ACR
echo "Pushing Docker image to ACR..."
docker push $ACR_NAME.azurecr.io/$DOCKER_IMAGE_NAME:$DOCKER_TAG

# # 9. Verify the image is pushed
# echo "Verifying Docker image in ACR..."
# az acr repository show-tags --name $ACR_NAME --repository $DOCKER_IMAGE_NAME --output table

# 10. Verify repository images in ACR
echo "Verifying repository images in ACR..."
az acr repository list --name $ACR_NAME --output table

echo "Docker image $DOCKER_IMAGE_NAME:$DOCKER_TAG has been pushed to ACR $ACR_NAME.azurecr.io."

# Output helpful info for further steps
echo "Use the following to integrate with AKS:"
echo "ACR Registry: $ACR_NAME"
echo "AKS Cluster: $AKS_CLUSTER_NAME"
echo "AKS Resource Group: $AKS_RESOURCE_GROUP"

echo "Attaching ACR $ACR_NAME to AKS cluster $AKS_CLUSTER_NAME..."
# Assign the 'User Access Administrator' role at the 'rg-acr-prod' level
az role assignment create \
  --assignee $ARM_CLIENT_ID \
  --role "User Access Administrator" \
  --scope "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$ACR_RESOURCE_GROUP"
az aks update -n $AKS_CLUSTER_NAME -g $AKS_RESOURCE_GROUP --attach-acr $ACR_NAME

# Optional: Helm deployment step if you want to run it after the AKS and ACR configuration
# cd ../deployment
# helm upgrade --install data-upload-app ./app-chart --values ./app-chart/dev-values.yaml
