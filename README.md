# DevOps Pipeline Project

## Project Description

This project demonstrates a DevOps pipeline that includes Terraform infrastructure deployment, Python-based data processing, and automated deployments using GitHub Actions. The pipeline is designed to deploy an S3 bucket and a CloudFront distribution on AWS, followed by a Python script that downloads, processes, and uploads data to the S3 bucket. The CloudFront distribution serves the processed data.

## Setup and Installation

### Prerequisites
- **Git:** Ensure you have Git installed on your system.
- **Python 3.x:** The project requires Python 3.x to run the scripts.
- **Terraform:** Terraform is required for infrastructure deployment.
- **AWS CLI:** The AWS CLI should be configured with the appropriate credentials.
- **GitHub Account:** A GitHub account is needed to push the repository and set up the CI/CD pipeline.

### Cloning the Repository
```bash
git clone <repository-url>
cd <repository-directory>
pip install -r python/requirements.txt    
```

## Usage Instructions

### Infrastructure Deployment

You can deploy the infrastructure locally using the provided script:

```bash
./scripts/deploy_infra.sh
```

This script will:

1. Deploy the S3 bucket in the `dev` environment.
2. Deploy the CloudFront distribution in the `dev` environment.
3. Capture the outputs (S3 bucket name, CloudFront domain name) and populate the `config.json` file.

### Running the Data Processing Script

After deploying the infrastructure, you can run the Python script to process and upload data:

```bash
./scripts/deploy_code.sh /path/to/config.json
```

This will:

1. Download data from a specified URL.
2. Filter the data based on predefined criteria.
3. Upload the filtered data to the S3 bucket.
4. Verify the uploaded data via the CloudFront distribution.

## Pipeline Structure

### Terraform
- **Modules:** Contains reusable Terraform modules for S3 and CloudFront.
- **Environments:** Contains environment-specific configurations (`dev`, `prod`).

### Python
- **src:** Contains the main Python script (`download_parse_upload.py`) and configuration (`config.json`).
- **tests:** Contains unit tests for the Python script.

### CI/CD with GitHub Actions
The CI/CD pipeline is defined in the `.github/workflows/infra-deployment.yml` and `.github/workflows/code-deployment.yml` files. It automates the deployment of infrastructure and the execution of the Python script.

## Testing

Unit tests for the Python script can be run using `unittest`:

```bash
python -m unittest discover python/tests
```

## Deployment

### CI/CD Pipeline

The pipeline includes:
1. **Infrastructure Deployment:** Automatically deploys the S3 bucket and CloudFront distribution.
2. **Code Deployment:** Automatically runs the Python script after successful infrastructure deployment.

### Manual Deployment

You can also manually deploy the code and infrastructure using the provided scripts.

## Configuration

The `config.json` file is dynamically updated during the infrastructure deployment. It contains:

- **url:** The URL to download the data from.
- **bucket_name:** The name of the S3 bucket.
- **s3_filename:** The filename for the uploaded data in S3.
- **cloudfront_domain:** The CloudFront domain serving the S3 content.
- **cloudfront_url:** The full URL to the uploaded data via CloudFront.

## Contact Information

For any questions or issues, please contact:

- **Name:** Dor Knafo
- **Email:** dorknafo@gmail.com
