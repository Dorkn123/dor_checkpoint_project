import os
import sys
import json
import requests
import boto3
from botocore.exceptions import NoCredentialsError, ClientError

def log(message):
    print(f"{message}")

def load_config(config_file):
    log(f"Loading config from: {config_file}")
    try:
        with open(config_file, 'r') as file:
            config = json.load(file)
            log(f"Config loaded successfully: {config}")
            return config
    except Exception as e:
        log(f"Error loading config: {e}")
        raise

def download_json(url):
    log(f"Downloading JSON data from: {url}")
    try:
        response = requests.get(url)
        response.raise_for_status()
        json_data = response.json()
        log("JSON data downloaded successfully.")
        return json_data
    except requests.exceptions.RequestException as e:
        log(f"Error downloading JSON data: {e}")
        raise

def filter_products(data, min_price=100):
    log(f"Filtering products with min price: {min_price}")
    try:
        filtered_products = [product for product in data['products'] if product['price'] >= min_price]
        log(f"Filtered products: {filtered_products}")
        return {"products": filtered_products}
    except KeyError as e:
        log(f"Error filtering products: Missing key {e}")
        raise

def save_to_json(data, filename):
    log(f"Saving data to JSON file: {filename}")
    try:
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
            log(f"Data saved successfully to {filename}")
    except Exception as e:
        log(f"Error saving data to JSON: {e}")
        raise

def upload_to_s3(file_path, bucket_name, s3_filename):
    region = os.getenv('AWS_DEFAULT_REGION', 'eu-north-1')
    log(f"Uploading {file_path} to S3 bucket {bucket_name} in region {region} as {s3_filename}")
    s3 = boto3.client('s3', region_name=region)
    try:
        s3.upload_file(file_path, bucket_name, s3_filename)
        log(f"File uploaded to S3: s3://{bucket_name}/{s3_filename}")
    except FileNotFoundError:
        log(f"Error: The file {file_path} was not found")
    except NoCredentialsError:
        log("Error: AWS credentials not available")
    except ClientError as e:
        log(f"Error uploading file to S3: {e}")
        raise

def download_from_cloudfront(url):
    log(f"Downloading file from CloudFront URL: {url}")
    try:
        response = requests.get(url)
        log(f"Response status code: {response.status_code}")
        log(f"Response headers: {response.headers}")
        response.raise_for_status()
        log("File downloaded successfully from CloudFront")
        return response.content
    except requests.exceptions.RequestException as e:
        log(f"Error downloading from CloudFront: {e}")
        raise


def main(config_path):
    log(f"Starting main process with config: {config_path}")
    config = load_config(config_path)

    # Extract values from config
    url = config.get('url')
    bucket_name = config.get('bucket_name')
    s3_filename = config.get('s3_filename')
    cloudfront_url = config.get('cloudfront_url')

    log(f"URL: {url}, Bucket: {bucket_name}, S3 Filename: {s3_filename}, CloudFront URL: {cloudfront_url}")

    # Step 1: Download JSON data
    data = download_json(url)

    # Step 2: Filter products based on price
    filtered_data = filter_products(data)

    # Step 3: Save filtered data to a local JSON file
    save_to_json(filtered_data, s3_filename)

    # Step 4: Upload the JSON file to S3
    upload_to_s3(s3_filename, bucket_name, s3_filename)

    # Step 5: Download the file via CloudFront and verify
    downloaded_content = download_from_cloudfront(cloudfront_url)
    if downloaded_content:
        log("Downloaded JSON from CloudFront successfully.")
    else:
        log("Failed to verify the download from CloudFront.")

if __name__ == "__main__":
    config_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), 'config.json')
    main(config_path)
