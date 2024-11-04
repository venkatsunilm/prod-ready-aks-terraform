# Set environment to 'dev' if not provided
export ENV=${1:-dev}

# Define common variables for logs and directories
LOG_DIR="/mnt/c/Users/harit/Documents/devops_test_logs"
BASE_DIR="/mnt/c/Users/harit/Documents/Visual Studio 2022/DevOps/DevOps-Terraform-Sample"
HELPER_DIR="$BASE_DIR/helper/scripts"
APP_DOCKER_PATH="$BASE_DIR/data-upload-app/src"
TF_APP_DIR="$BASE_DIR/data-upload-app/deployment"

# Ensure log directory exists
mkdir -p $LOG_DIR

# Function to run a script with logging and a delay
run_with_logging() {
    local script_path="$1"
    local log_file="$2"
    
    echo "Running $script_path..."
    source "$script_path"

    # Log output separately
    date >> "$log_file"
    cat "$script_path" >> "$log_file"
    
    sleep 5
}

# Step 0: Set the local environments
export ENV_DIR="$BASE_DIR"
run_with_logging "$HELPER_DIR/0_local_env_setup.sh" \
 "$LOG_DIR/app_environments_output.log"

# Check necessary environment variables
if [ -z "$TF_VAR_environment" ]; then
    echo "Error: Required environment variables are not set."
    exit 1
fi

# Step 1: Set the AKS cluster configuration
export TF_DIR="$TF_APP_DIR"
run_with_logging "$HELPER_DIR/2_set_aks-cluster-config.sh" \
 "$LOG_DIR/app_aks_config_output.log"

# Step 2: Deploy Docker image to ACR
export APP_PATH="$APP_DOCKER_PATH"
run_with_logging "$HELPER_DIR/3_deploy_image_acr.sh" \
 "$LOG_DIR/app_docker_acr_output.log"

# Step 3: Run the Terraform script
export TF_DIR="$TF_APP_DIR"
export DEPLOY_TYPE="application"
run_with_logging "$HELPER_DIR/1_run_terraform.sh" \
 "$LOG_DIR/app_terraform_output.log"
