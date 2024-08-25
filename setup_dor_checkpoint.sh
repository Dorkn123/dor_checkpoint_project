#!/bin/bash

# Create the project root directory
mkdir dor_checkpoint

# Navigate into the project directory
cd dor_checkpoint

# Create Terraform directories
mkdir -p terraform/modules/s3
mkdir -p terraform/modules/cloudfront
mkdir -p terraform/environments/dev
mkdir -p terraform/environments/prod

# Create the main Terraform files
touch terraform/terragrunt.hcl
touch terraform/provider.tf
touch terraform/versions.tf

# Create S3 module files
touch terraform/modules/s3/main.tf
touch terraform/modules/s3/variables.tf
touch terraform/modules/s3/outputs.tf

# Create CloudFront module files
touch terraform/modules/cloudfront/main.tf
touch terraform/modules/cloudfront/variables.tf
touch terraform/modules/cloudfront/outputs.tf

# Create Terragrunt environment files
touch terraform/environments/dev/terragrunt.hcl
touch terraform/environments/prod/terragrunt.hcl

# Create Python directories
mkdir -p python/src
mkdir -p python/tests

# Create Python script and test files
touch python/src/download_parse_upload.py
touch python/tests/test_download_parse_upload.py
touch python/requirements.txt
touch python/__init__.py

# Create GitHub Actions workflow directories
mkdir -p .github/workflows

# Create GitHub Actions workflow files
touch .github/workflows/infra-deployment.yml
touch .github/workflows/code-deployment.yml

# Create scripts directory and deploy scripts
mkdir scripts
touch scripts/deploy_infra.sh
touch scripts/deploy_code.sh

# Create README and .gitignore files
touch README.md
touch .gitignore

echo "Project structure for dor_checkpoint created successfully."
