# azure-aks-terraform-github-actions-helm

## Overview
This production ready project involves infrastructure provisioning using **Terraform** and application deployment with **Helm** on **Azure Kubernetes Service (AKS)**. The project is structured to separate the management of infrastructure and application deployment, with clear environment-specific configurations for dev and prod environments.

## Directory Structure

### 1. Workflows Directory
This directory contains the CI/CD pipeline configuration files for both infrastructure and application deployment.

- **deploy-infra-cicd.yml**: Manages the infrastructure provisioning workflow, including the deployment of AKS, ACR, networking, and storage resources.
- **deploy-app-cicd.yml**: Handles the application deployment workflow using Helm, ensuring the web app is properly deployed to AKS.

### 2. Modules Directory
This directory holds the Terraform modules for deploying specific infrastructure components.

- **storage/**: Provisions Azure Storage resources for application data or other infrastructure needs.

### 3. Deployment Directory
Contains the main Terraform configuration files that define and manage the infrastructure deployment process.

- **main.tf**: The entry point for Terraform, which ties together the modules and manages resource dependencies.
- **variables.tf**: Defines variables that are used across the Terraform configuration for flexibility and reusability.
- **outputs.tf**: Specifies the output variables, such as the AKS cluster name or public IP, that are available after the infrastructure is provisioned.
- **dev.tfvars** and **prod.tfvars**: Environment-specific variable files for dev and prod, ensuring that different configurations can be applied depending on the environment.

### 4. App Helm Chart
This directory holds the Helm chart for deploying the web application to AKS.

- **app-chart/**: Helm chart directory containing Kubernetes manifest templates for the web application deployment.
- **Chart.yaml**: The metadata file that defines the Helm chart's version, name, and dependencies.
- **dev-values.yaml**: Values file containing configurations specific to the dev environment.
- **prod-values.yaml**: Values file containing configurations specific to the prod environment.

### 5. Source Code (src)
This directory contains the application's source code and associated resources.

- **app.py**: The main Python file that contains the web application code.
- **Dockerfile**: Defines the instructions to build the Docker image for the web application.
- **data_export.sh**: A shell script used for exporting data.
- **requirements.txt**: Lists the Python dependencies required by the web application.

## How to Use

### Prerequisites
- **Azure Account**: You need an active Azure account to provision resources like AKS and ACR.
- **Terraform**: Install [Terraform](https://www.terraform.io/downloads) to manage infrastructure.
- **Helm**: Install [Helm](https://helm.sh/docs/intro/install/) to deploy the web app.
- **Azure CLI**: Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) to interact with Azure services.

### Steps to Deploy

#### 1. Infrastructure Provisioning:
1. Clone this repository.
2. Navigate to the `deployment` directory.
3. Run Terraform commands:
   ```bash
   terraform init
   terraform plan -var-file=dev.tfvars
   terraform apply -var-file=dev.tfvars
   ```
4. This will provision AKS, ACR, and other necessary infrastructure resources.

#### 2. Application Deployment:
1. After the infrastructure is set up, navigate to the `src` folder to build and push the Docker image:
   ```bash
   docker build -t <acr_registry_name>.azurecr.io/data-upload-app:latest .
   docker push <acr_registry_name>.azurecr.io/data-upload-app:latest
   ```
2. Navigate to the `app-chart` directory.
3. Use Helm to deploy the application:
   ```bash
   helm upgrade --install data-upload-app ./app-chart --values ./app-chart/dev-values.yaml
   ```

### CI/CD Pipeline
The project includes two CI/CD pipelines:

1. **Infrastructure CI/CD (deploy-infra-cicd.yml)**: This pipeline automates the provisioning of infrastructure using Terraform.
2. **Application CI/CD (deploy-app-cicd.yml)**: This pipeline automates the build, push, and deployment of the web application using Docker and Helm.

### Environment-Specific Configurations
- **Development**: Use `dev.tfvars` and `dev-values.yaml` for dev environment deployment.
- **Production**: Use `prod.tfvars` and `prod-values.yaml` for prod environment deployment.

## Project sturcture and it's design

The idea of this structure is to support a clear separation between infrastructure provisioning and application deployment using Terraform, Helm, Docker, and AKS. The GitHub Actions workflows automate both infrastructure and application deployments, with the reusable actions (such as k8s-setup-action) simplifying Kubernetes management tasks.

### Project Structure Overview

DEVOPS-TERRAFORM-SAMPLE/
│
├── .github/
│   └── actions/
│       ├── terraform-action/
│       ├── docker-action/
│       └── k8s-setup-action/
│   └── workflows/
│       ├── deploy-infra-cicd.yml
│       └── deploy-app-cicd.yml
│
├── azure-platform/
│   ├── deployment/
│   └── modules/
├── data-upload-app/
│   ├── deployment/
│   └── modules/
├── helper/
│   └── scripts/
├── .gitignore
└── README.md

### A deep look at the Project sturcture and it's design
azure-aks-terraform-github-actions/
│
├── .github/
│   └── actions/
│       ├── terraform-action/         # Composite action to run Terraform commands
│       ├── docker-action/            # Composite action to build and push Docker images
│       └── k8s-setup-action/         # Composite action to set up Kubernetes (AKS)
│   └── workflows/
│       ├── deploy-infra-cicd.yml     # GitHub Actions workflow for infrastructure deployment
│       └── deploy-app-cicd.yml       # GitHub Actions workflow for application deployment
│
├── azure-platform/
│   ├── deployment/
│   │   ├── .terraform/               # Terraform-related files and configurations
│   │   ├── data.tf                   # Data source definitions
│   │   ├── dev.tfvars                # Environment-specific variables for dev
│   │   ├── locals.tf                 # Local variables used in Terraform
│   │   ├── main.tf                   # Main infrastructure configuration (AKS, Networking, etc.)
│   │   ├── outputs.tf                # Output values from Terraform (e.g., AKS name, resource group)
│   │   ├── prod.tfvars               # Environment-specific variables for prod
│   │   ├── providers.tf              # Provider configuration for Azure (azurerm)
│   │   ├── versions.tf               # Terraform version and provider version constraints
│   └── modules/
│       └── storage/
│           ├── locals.tf             # Local variables for Storage
│           ├── main.tf               # Azure Blob Storage and Terraform backend configuration
│           └── variables.tf          # Variables for Storage
│
├── data-upload-app/
│   ├── deployment/
│   │   ├── .terraform/               # Terraform files for the application deployment
│   │   ├── dev.tfvars                # Environment-specific variables for dev
│   │   ├── main.tf                   # Helm chart deployment using Terraform
│   │   ├── outputs.tf                # Outputs related to app deployment
│   │   ├── prod.tfvars               # Environment-specific variables for prod
│   │   ├── providers.tf              # Providers for the app deployment
│   │   ├── variables.tf              # Variables for the app deployment
│   └── modules/
│       ├── app-chart/
│       │   ├── templates/            # Helm chart templates (deployment, service, ingress, etc.)
│       │   ├── Chart.yaml            # Helm chart configuration
│       │   ├── dev-values.yaml       # Helm values for dev environment
│       │   ├── prod-values.yaml      # Helm values for prod environment
│       └── src/
│           ├── Dockerfile            # Dockerfile for building the web application image
│           ├── app.py                # Main application code (Python, Flask or similar)
│           ├── requirements.txt      # Python dependencies
│
├── helper/
│   └── scripts/
│       ├── 0_local_env_setup.sh      # Script for setting up local development environment (git ignored)
│       ├── 1_run_terraform.sh        # Script to run Terraform commands
│       ├── 2_set_aks-cluster-config.sh # Script to configure AKS cluster
│       ├── 3_deploy_image_acr.sh     # Script to deploy Docker images to ACR
│       ├── 4_run_terraform_destroy.sh # Script to destroy infrastructure via Terraform
│       ├── check_acr_attach_aks.sh   # Script to check ACR attachment with AKS
│       ├── delete_all_rg_except.sh   # Script to delete all resource groups except specific ones
│       ├── git_add_amend_pushf.sh    # Script for Git add, amend, and push
│       ├── git_switch_rebase.sh      # Script to switch branches and rebase in Git
│       ├── tf_backend_storage.sh     # Script to set up backend storage for Terraform state (git ignored)
│
├── .gitignore                        # Git ignore file for Terraform and other generated files
└── README.md                         # Project overview and documentation

## License
This project is licensed under the MIT License.

DEVOPS-TERRAFORM-SAMPLE/ │ ├── .github/ # GitHub Actions workflows and custom actions │ └── actions/ │ └── workflows/ │ ├── azure-platform/ # Terraform files for infrastructure provisioning │ ├── deployment/ │ └── modules/ │ ├── data-upload-app/ # Application source code, Helm charts, and Terraform for app deployment │ ├── deployment/ │ └── modules/ │ ├── helper/ # Helper scripts for managing infrastructure and app deployment └── README.md #