
# CI/CD Workflows for AKS and Application Deployment

This repository implements a fully automated CI/CD pipeline for deploying infrastructure and applications on Azure Kubernetes Service (AKS) using GitHub Actions, Terraform, Docker, and Helm. The pipeline consists of two main workflows:

1. **Infrastructure Deployment Workflow**
2. **Application Deployment Workflow**

## Workflows Overview

### 1. **Infrastructure Deployment Workflow**

This workflow is responsible for provisioning the Azure infrastructure, including AKS, Azure Container Registry (ACR), networking, and other related resources. It leverages **Terraform** to deploy and manage infrastructure in a scalable manner.

- **Workflow File**: `.github/workflows/deploy-infra-cicd.yml`
- **Triggers**: 
  - Push to branches: `main`, `develop`, or feature branches (`feat_*`).
  - Can also be triggered manually via `workflow_dispatch`.
- **Key Steps**:
  - Checkout code.
  - Run Terraform to provision resources.
  - Capture key outputs (`AKS_CLUSTER_NAME`, `AKS_RESOURCE_GROUP`, `ACR_REGISTRY_NAME`) and save them as a JSON artifact (`infra-outputs`).

### 2. **Application Deployment Workflow**

This workflow is responsible for deploying the application to the AKS cluster. It includes building the Docker image, pushing it to ACR, and deploying the image using **Helm** on AKS. The workflow retrieves infrastructure details from the artifact generated by the infrastructure deployment workflow.

- **Workflow File**: `.github/workflows/deploy-app-cicd.yml`
- **Triggers**:
  - Runs after the infrastructure deployment completes (via `workflow_run`).
  - Can also be triggered manually via `workflow_dispatch`.
- **Key Steps**:
  - Checkout code.
  - Download the infrastructure artifact (`infra-outputs`).
  - Build and push the Docker image to ACR.
  - Use **Helm** to deploy the application on AKS.

## Reusable Actions

We have created reusable composite actions to modularize and simplify the workflows. These actions help manage Kubernetes setup, Docker image building, and Terraform provisioning.

### 1. **Kubernetes Setup Action**

This reusable action handles the setup of `kubectl`, logging into Azure, retrieving AKS credentials, and checking the Kubernetes context.

- **Action Location**: `.github/actions/k8s-setup-action/action.yml`
- **Inputs**:
  - `aks_cluster_name`: The name of the AKS cluster.
  - `aks_resource_group`: The resource group containing the AKS cluster.
  - `acr_registry_name`: The name of the Azure Container Registry (ACR).
  - `azure_credentials`: Azure login credentials (via GitHub Secrets).

### 2. **Docker Build & Push Action**

This reusable action builds a Docker image from the application code and pushes it to the ACR.

- **Action Location**: `.github/actions/docker-action/action.yml`
- **Inputs**:
  - `image_name`: Name of the Docker image.
  - `registry_name`: ACR registry name.
  - `version`: The image version.
  - `working-directory`: Directory containing the Dockerfile.

### 3. **Terraform Action**

This reusable action handles common Terraform tasks such as initializing, planning, and applying configurations across multiple environments.

- **Action Location**: `.github/actions/terraform-action/action.yml`
- **Inputs**:
  - `environment`: The environment for deployment (e.g., dev, prod).
  - `working-directory`: The directory containing the Terraform configuration files.

## Key Challenges Addressed

### 1. **Passing Values Between Workflows**
Artifacts are used to pass key values (e.g., AKS cluster name, resource group, ACR name) between the infrastructure and application workflows. These values are saved in a JSON file and uploaded as artifacts in the infrastructure workflow, then downloaded and used in the application workflow.

### 2. **Context Management in Workflows**
To ensure that values like `AKS_CLUSTER_NAME` and `ACR_REGISTRY_NAME` are accessible throughout the workflow, they are exported to the environment using the `GITHUB_ENV` file. This makes them available across steps.

### 3. **Reusable Actions for Consistency**
By modularizing common tasks like Kubernetes setup, Docker image building, and Terraform commands, we ensure that the workflows are consistent, maintainable, and scalable across multiple environments.

## How to Use the CI/CD Pipelines

### Running the Infrastructure Workflow

1. Push changes to `main`, `develop`, or a feature branch (`feat_*`), or trigger it manually via GitHub's **Actions** tab.
2. The infrastructure will be provisioned, and key outputs will be saved as an artifact for use in the application workflow.

### Running the Application Workflow

1. The application workflow will be triggered automatically when the infrastructure workflow completes.
2. Alternatively, you can manually run the application workflow via the **Actions** tab.

## Secrets and Configuration

The following secrets should be configured in the GitHub repository for the workflows to function:

- **`AZURE_CREDENTIALS`**: Azure service principal credentials for authenticating with Azure.
- **`ARM_CLIENT_ID`**, **`ARM_CLIENT_SECRET`**, **`ARM_TENANT_ID`**, **`ARM_SUBSCRIPTION_ID`**: These values are used by Terraform to authenticate with Azure.

---

For more details on how to modify and extend the pipelines, refer to the individual workflow files and actions within this repository.
