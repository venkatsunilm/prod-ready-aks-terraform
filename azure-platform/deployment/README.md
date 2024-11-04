## How to run terrafom locally

# Go to working directory

working-directory: environments/shared
export TF_VAR_environment="dev"
NOTE: dev.tfvars and prod.tfvars are generated dynamically in the pipeline by fetching the values from the GihHub Secrets for now.

# Terraform init

terraform init

# Terraform Plan

terraform plan -var-file="../$TF_VAR_environment.tfvars"

# Terraform Apply

terraform apply -var-file="../$TF_VAR_environment.tfvars" -auto-approve

# Terraform Destroy

terraform destroy -var-file="../$TF_VAR_environment.tfvars" -auto-approve

# Additional info

- name: Terraform Init
  run: terraform init -backend-config="resource_group_name=rg-terraform-backend" \
   -backend-config="storage_account_name=tfstate1727630878" \
   -backend-config="container_name=tfstate" \
   -backend-config="key=dev.terraform.tfstate"
