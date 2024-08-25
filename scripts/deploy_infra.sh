#!/bin/bash

# Set AWS Region (if not already set)
export AWS_DEFAULT_REGION="eu-north-1"

# Deploy S3 in dev environment
cd terraform/environments/dev/s3
terragrunt init
terragrunt apply -auto-approve
BUCKET_NAME=$(terragrunt output -raw bucket_name)

# Deploy CloudFront in dev environment
cd ../cloudfront
terragrunt init
terragrunt apply -auto-approve

# # Repeat for prod environment

# # Deploy S3 in prod environment
# cd ../../prod/s3
# terragrunt init
# terragrunt apply -auto-approve

# # Deploy CloudFront in prod environment
# cd ../cloudfront
# terragrunt init
# terragrunt apply -auto-approve


# Capture the outputs
CLOUDFRONT_DOMAIN=$(terragrunt output -raw cloudfront_domain_name)


# Update config.json with the captured outputs
CONFIG_FILE="/home/dor/dor_checkpoint/python/src/config.json"
jq ".bucket_name=\"$BUCKET_NAME\" | .cloudfront_domain=\"$CLOUDFRONT_DOMAIN\" | .cloudfront_url=\"https://$CLOUDFRONT_DOMAIN/filtered_products.json\"" $CONFIG_FILE > tmp.$$.json && mv tmp.$$.json $CONFIG_FILE

echo "Updated config.json with the following values:"
echo "bucket_name: $BUCKET_NAME"
echo "cloudfront_domain: $CLOUDFRONT_DOMAIN"