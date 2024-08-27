#!/bin/bash

# Load AWS credentials only if not running in CI
if [ -z "$GITHUB_ACTIONS" ]; then
    source creds/aws_credentials.sh
fi

export AWS_DEFAULT_REGION="eu-north-1"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Deploy S3 in dev environment
cd "$SCRIPT_DIR/../terraform/environments/dev/s3"
terragrunt init
terragrunt apply -auto-approve
BUCKET_NAME=$(terragrunt output -raw bucket_name)

# Check if CloudFront distribution already exists for this S3 bucket
EXISTING_DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[0].DomainName=='${BUCKET_NAME}.s3.amazonaws.com'].Id" --output text)

if [ -z "$EXISTING_DISTRIBUTION_ID" ]; then
    echo "No existing CloudFront distribution found. Creating a new distribution."
    
    # Deploy CloudFront in dev environment
    cd ../cloudfront
    terragrunt init
    terragrunt apply -auto-approve
    CLOUDFRONT_DOMAIN=$(terragrunt output -raw cloudfront_domain_name)
    CLOUDFRONT_ID=$(terragrunt output -raw cloudfront_distribution_id)
else
    echo "Existing CloudFront distribution found: $EXISTING_DISTRIBUTION_ID"
    CLOUDFRONT_ID=$EXISTING_DISTRIBUTION_ID
    CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution --id $CLOUDFRONT_ID --query "Distribution.DomainName" --output text)
    
    # Perform CloudFront invalidation
    aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths "/*"
fi

# Path to the config.json file
CONFIG_FILE="$SCRIPT_DIR/../python/src/config.json"

# Update config.json with the captured outputs
jq ".bucket_name=\"$BUCKET_NAME\" | .cloudfront_domain=\"$CLOUDFRONT_DOMAIN\" | .cloudfront_url=\"https://$CLOUDFRONT_DOMAIN/filtered_products.json\"" $CONFIG_FILE > tmp.$$.json && mv tmp.$$.json $CONFIG_FILE

echo "Updated config.json with the following values:"
echo "bucket_name: $BUCKET_NAME"
echo "cloudfront_domain: $CLOUDFRONT_DOMAIN"
