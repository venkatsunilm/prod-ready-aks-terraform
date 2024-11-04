# Call local_env_setup.sh to export necessary environment variables
# source "/mnt/c/Users/harit/Documents/Visual Studio 2022/DevOps/DevOps-Terraform-Sample/helper/scripts/0_local_env_setup.sh"

# Check if TF_DIR is set, if not, use the current directory
if [ -z "$TF_DIR" ]; then
  echo "TF_DIR is not set. Using the current directory as TF_DIR."
  TF_DIR=$(pwd)
else
  echo "Using TF_DIR: $TF_DIR"
fi

cd "$TF_DIR" || { echo "Directory $TF_DIR not found"; exit 1; }

# Check if AKS_CLUSTER_NAME is exported correctly
if [ -z "$AKS_CLUSTER_NAME" ]; then
  echo "Error: AKS_CLUSTER_NAME is not set. Please ensure it is exported in local_env_setup.sh."
  exit 1
fi

az account show

# 1. Get AKS Credentials
echo "Fetching AKS credentials for cluster $AKS_CLUSTER_NAME in resource group $AKS_RESOURCE_GROUP..."
az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --admin --overwrite-existing

HOME="/mnt/c/Users/harit"
KUBECONFIG_PATH="$HOME/.kube/config"  # Default kubeconfig path (you can adjust if needed)

export KUBECONFIG=$HOME/.kube/config
export KUBE_CONFIG_PATH=$HOME/.kube/config

# 2. Get available Kubernetes Context
kubectl config get-contexts

# 3. Set and Verify the Kubernetes Context
echo "Setting Kubernetes context to $AKS_CLUSTER_NAME..."
kubectl config use-context $AKS_CLUSTER_NAME-admin

# 3. Verify the current context
echo "Verifying current Kubernetes context:"
kubectl config current-context

# 4. Check the KUBECONFIG file path
if [ -f "$KUBECONFIG" ]; then
    echo "KUBECONFIG is set to: $KUBECONFIG"
else
    echo "KUBECONFIG not found at the expected path: $KUBECONFIG"
fi

# 5. Get the nodes in the AKS cluster
echo "Fetching AKS nodes:"
kubectl get nodes

# 6. Get the pods in the current namespace
echo "Fetching pods in the current namespace:"
kubectl get pods

echo "verify the service"
kubectl get services

echo "Done."
