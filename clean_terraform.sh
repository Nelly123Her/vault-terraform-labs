#!/bin/bash

# Check if a directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

TARGET_DIR="$1"

# Ensure the specified directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory '$TARGET_DIR' does not exist."
  exit 1
fi

echo "Cleaning Terraform files and folders inside '$TARGET_DIR' and its subdirectories..."

# Find and delete the specified Terraform files and directories
find "$TARGET_DIR" -type f -name "terraform.tfstate" -exec rm -f {} \;
find "$TARGET_DIR" -type f -name "terraform.tfstate.backup" -exec rm -f {} \;
find "$TARGET_DIR" -type d -name ".terraform" -exec rm -rf {} +;
find "$TARGET_DIR" -type f -name ".terraform.lock.hcl" -exec rm -f {} \;

echo "Cleanup complete!"
