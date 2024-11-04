#!/bin/bash

echo "Starting data export script"

# Function to check if AzCopy is installed
check_azcopy_installed() {
    if command -v azcopy &> /dev/null; then
        echo "AzCopy is already installed."
        azcopy --version
        return 0
    else
        echo "AzCopy is not installed."
        return 1
    fi
}

# Function to install AzCopy for Linux
install_azcopy() {
    echo "Installing AzCopy..."
    wget https://aka.ms/downloadazcopy-v10-linux -O azcopy_linux.tar.gz
    tar -xvf azcopy_linux.tar.gz
    mkdir -p $HOME/azcopy
    mv ./azcopy_linux_amd64_*/azcopy $HOME/azcopy/
    rm -f azcopy_linux.tar.gz
    rm -rf azcopy_linux_amd64_*
    export PATH=$HOME/azcopy:$PATH
    echo "AzCopy installed at $HOME/azcopy"
    azcopy --version
}

# Function to perform the file upload using AzCopy
upload_file_with_azcopy() {
    local_file_path="$1"
    sas_token="$2"
    echo "Uploading $local_file_path to Azure Blob Storage using AzCopy..."
    azcopy copy "$local_file_path" \
        "https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/$AZURE_STORAGE_CONTAINER/$(basename "$local_file_path")?$sas_token" \
        --recursive=true
    echo "File uploaded successfully."
}

# Main script logic

# Make the script executable
chmod +x "$(basename "$0")"

# Check if AzCopy is installed, and install if necessary
if ! check_azcopy_installed; then
    install_azcopy
fi

# # Set the environment variables
# AZURE_STORAGE_ACCOUNT="ffmproject"
# AZURE_STORAGE_CONTAINER="testdatavenkat"

# Call the function to upload the file
local_file="$1"
sas_token="$2"
AZURE_STORAGE_ACCOUNT="$3"
AZURE_STORAGE_CONTAINER="$4"

echo "local_file: $local_file"
echo "sas_token: $sas_token"
upload_file_with_azcopy "$local_file" "$sas_token"
