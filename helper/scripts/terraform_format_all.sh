# Script will run terraform fmt in all directories containing .tf files
BASE_DIR="/mnt/c/Users/harit/Documents/Visual Studio 2022/DevOps/DevOps-Terraform-Sample"

# Change to the directory where Terraform files are located
cd "$BASE_DIR" || { echo "Directory $BASE_DIR not found"; exit 1; }

for dir in $(find . -type f -name "*.tf" -exec dirname {} \; | sort -u); do
    echo "Running terraform fmt in $dir"
    (cd "$dir" && terraform fmt -recursive)
done

