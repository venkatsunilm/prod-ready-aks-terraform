# Directory to run Terraform commands
TF_INFRA_DIR="/mnt/c/Users/harit/Documents/Visual Studio 2022/DevOps/DevOps-Terraform-Sample/azure-platform/deployment"
TF_APP_DIR="/mnt/c/Users/harit/Documents/Visual Studio 2022/DevOps/DevOps-Terraform-Sample/data-upload-app/deployment"

# Set the environment variable to dev
# export TF_VAR_environment="dev"

TF_DIR="${TF_DIR:-$TF_INFRA_DIR}"

run_terraform() {
    # Change to the directory where Terraform files are located
    cd "$TF_DIR" || { echo "Directory $TF_DIR not found"; return 1; }

    # Initialize Terraform
    echo "Initializing Terraform in directory: $TF_VAR_environment/$DEPLOY_TYPE.tfstate"
    if ! terraform init \
      -backend-config="key=$TF_VAR_environment/$DEPLOY_TYPE.tfstate"; then
      echo "Terraform initialization failed!"
      return 1
    fi

    # Plan with the specified environment variable
    # echo "Running Terraform plan for environment: $TF_VAR_environment"
    # terraform plan -var-file="./$TF_VAR_environment.tfvars" || return 1

    # Apply with the specified environment variable and auto-approve
    echo "Applying Terraform configuration for environment: $TF_VAR_environment"
    # Uncomment the line below to apply
    terraform apply -var-file="./$TF_VAR_environment.tfvars" -auto-approve || return 1

    # Optional: Destroy with the specified environment variable and auto-approve
    # echo "Destroying Terraform resources for environment: $TF_VAR_environment"
    # Uncomment the line below to destroy
    # terraform destroy -var-file="./$TF_VAR_environment.tfvars" -auto-approve || return 1
}

run_terraform