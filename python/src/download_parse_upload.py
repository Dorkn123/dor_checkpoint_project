import os
import sys
import json
import requests
import boto3
from botocore.exceptions import NoCredentialsError

def load_config(config_file):
    print(f"Loading config from: {config_file}")
    with open(config_file, 'r') as file:
        return json.load(file)

def download_json(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Failed to download JSON data: {response.status_code}")

def filter_products(data, min_price=100):
    filtered_products = [product for product in data['products'] if product['price'] >= min_price]
    return {"products": filtered_products}

def save_to_json(data, filename):
    with open(filename, 'w') as f:
        json.dump(data, f)

def upload_to_s3(filename, bucket_name, s3_filename):
    s3 = boto3.client('s3', region_name=os.getenv('AWS_DEFAULT_REGION', 'eu-north-1'))
    try:
        s3.upload_file(filename, bucket_name, s3_filename)
        print(f"File uploaded to S3: s3://{bucket_name}/{s3_filename}")
    except FileNotFoundError:
        print("The file was not found")
    except NoCredentialsError:
        print("Credentials not available")



def download_from_cloudfront(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.content
    else:
        raise Exception(f"Failed to download JSON from CloudFront: {response.status_code}")

def main(config_path):
    config = load_config(config_path)  # Load configuration from config.json

    # Extract values from config
    url = config['url']
    bucket_name = config['bucket_name']
    s3_filename = config['s3_filename']
    cloudfront_domain = config['cloudfront_domain'] or os.getenv('CLOUDFRONT_DOMAIN')
    cloudfront_url = config['cloudfront_url'] or f"https://{cloudfront_domain}/{s3_filename}"

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
        print("Downloaded JSON from CloudFront successfully.")

if __name__ == "__main__":
    config_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), 'config.json')
    main(config_path)
