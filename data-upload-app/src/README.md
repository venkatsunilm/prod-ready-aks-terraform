# Create docker image and container

docker build -t data-upload-app .
docker run -d -p 8000:8000 data-upload-app

# Create RG

az group create --name rg-acr-dev --location eastus

# Login and create ACR

az acr login --name venkatsunilm
az acr create --resource-group rg-acr-dev --name venkatsunilm --sku Basic

# Push Docker Image to Container Registry:

docker tag data-upload-app venkatsunilm.azurecr.io/data-upload-app:latest
docker push venkatsunilmdev.azurecr.io/data-upload-app:latest

<!-- acr_registry_name = "venkatsunilm"
aks_cluster_name = "aks-dev"
aks_rg_name = "rg-dev" -->
