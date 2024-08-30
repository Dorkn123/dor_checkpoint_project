#!/bin/bash
set -e

# Load AWS credentials only if not running in CI
if [ -z "$GITHUB_ACTIONS" ]; then
    source creds/aws_credentials.sh
fi

# Set the deployment environment (default to 'dev' if not provided)
ENVIRONMENT="${ENVIRONMENT:-dev}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-north-1}"
BUCKET_NAME="dor-checkpoint-assets-$ENVIRONMENT"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../python/src/config.json"
TERRAGRUNT_FILE="$SCRIPT_DIR/../terraform/environments/$ENVIRONMENT/cloudfront/terragrunt.hcl"
BACKUP_FILE="$TERRAGRUNT_FILE.bak"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to retrieve S3 bucket ARN
get_bucket_arn() {
    echo "arn:aws:s3:::$1"
}

backup_terragrunt_file() {
    log "Backing up CloudFront terragrunt.hcl to $BACKUP_FILE"
    cp "$TERRAGRUNT_FILE" "$BACKUP_FILE"
}

restore_terragrunt_file() {
    log "Restoring CloudFront terragrunt.hcl from $BACKUP_FILE"
    cp "$BACKUP_FILE" "$TERRAGRUNT_FILE"
    rm "$BACKUP_FILE"
}

check_s3_bucket() {
    log "Checking if S3 bucket exists: $BUCKET_NAME"
    local bucket_exists=$(aws s3api head-bucket --bucket $BUCKET_NAME 2>&1 || true)
    
    if echo "$bucket_exists" | grep -q 'Not Found'; then
        log "S3 bucket does not exist. Creating a new bucket."
        cd "$SCRIPT_DIR/../terraform/environments/$ENVIRONMENT/s3"
        terragrunt apply -auto-approve
        BUCKET_ARN=$(terragrunt output -raw bucket_arn)
    elif echo "$bucket_exists" | grep -q 'Forbidden'; then
        log "S3 bucket exists but access is forbidden."
        exit 1
    else
        log "S3 bucket exists."
        BUCKET_ARN=$(get_bucket_arn "$BUCKET_NAME")
    fi
}

update_terragrunt_inputs() {
    log "Updating CloudFront terragrunt.hcl with bucket_name: $BUCKET_NAME and bucket_arn: $BUCKET_ARN"
    
    sed -i "s/dependency.s3.outputs.bucket_name/\"$BUCKET_NAME\"/g" "$TERRAGRUNT_FILE"
    sed -i "s/dependency.s3.outputs.bucket_arn/\"$BUCKET_ARN\"/g" "$TERRAGRUNT_FILE"

    log "CloudFront terragrunt.hcl updated successfully."
}

check_cloudfront() {
    log "Checking if CloudFront distribution exists for bucket: $BUCKET_NAME"

    # Get all distribution IDs and their last modified times
    local distribution_data=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[0].DomainName=='${BUCKET_NAME}.s3.amazonaws.com'].{Id:Id, LastModifiedTime:LastModifiedTime}" --output json)

    # Check if no distributions are found
    if [ -z "$distribution_data" ] || [ "$distribution_data" == "[]" ]; then
        log "No existing CloudFront distribution found. Creating a new distribution."
        cd "$SCRIPT_DIR/../terraform/environments/$ENVIRONMENT/cloudfront"
        terragrunt apply -auto-approve
        CLOUDFRONT_DOMAIN=$(terragrunt output -raw cloudfront_domain_name)
    else
        # Find the distribution with the latest LastModifiedTime
        local selected_distribution_id=$(echo "$distribution_data" | jq -r 'max_by(.LastModifiedTime) | .Id')

        log "Selected CloudFront distribution ID: $selected_distribution_id (most recently modified)."
        CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution --id "$selected_distribution_id" --query "Distribution.DomainName" --output text)
        
        if [ -z "$CLOUDFRONT_DOMAIN" ]; then
            log "Error: Unable to retrieve the CloudFront domain name. Please check the CloudFront distribution."
            exit 1
        fi
        
        log "Invalidating CloudFront cache."
        aws cloudfront create-invalidation --distribution-id "$selected_distribution_id" --paths "/*" || log "Failed to invalidate CloudFront cache"
    fi
}


update_config() {
    log "Updating config.json with bucket_name: $BUCKET_NAME and cloudfront_domain: $CLOUDFRONT_DOMAIN"
    jq ".bucket_name=\"$BUCKET_NAME\" | .cloudfront_domain=\"$CLOUDFRONT_DOMAIN\" | .cloudfront_url=\"https://$CLOUDFRONT_DOMAIN/filtered_products.json\"" "$CONFIG_FILE" > tmp.$$.json && mv tmp.$$.json "$CONFIG_FILE"
    log "config.json updated successfully."
}

main() {
    # Backup the CloudFront terragrunt.hcl file
    backup_terragrunt_file

    # Attempt to deploy infrastructure
    set +e
    check_s3_bucket
    update_terragrunt_inputs
    check_cloudfront
    update_config
    local exit_code=$?
    set -e

    # Rollback if deployment failed
    if [ $exit_code -ne 0 ]; then
        log "Deployment failed, rolling back terragrunt.hcl to its original state."
        restore_terragrunt_file
        exit $exit_code
    else
        # Clean up the backup if everything succeeded
        rm "$BACKUP_FILE"
    fi
}

main
