import os
import sys
import json
import requests
import boto3
from botocore.exceptions import NoCredentialsError

def load_config(config_file):
    print(f"Loading config from: {config_file}")
    try:
        with open(config_file, 'r') as file:
            config = json.load(file)
            print(f"Config loaded successfully: {config}")
            return config
    except Exception as e:
        print(f"Error loading config: {e}")
        raise

def download_json(url):
    print(f"Downloading JSON data from: {url}")
    try:
        response = requests.get(url)
        print(f"Received response: {response.status_code}")
        if response.status_code == 200:
            json_data = response.json()
            print(f"JSON data downloaded successfully: {json_data}")
            return json_data
        else:
            raise Exception(f"Failed to download JSON data: {response.status_code}")
    except Exception as e:
        print(f"Error downloading JSON data: {e}")
        raise

def filter_products(data, min_price=100):
    print(f"Filtering products with min price: {min_price}")
    try:
        filtered_products = [product for product in data['products'] if product['price'] >= min_price]
        print(f"Filtered products: {filtered_products}")
        return {"products": filtered_products}
    except Exception as e:
        print(f"Error filtering products: {e}")
        raise

def save_to_json(data, filename):
    print(f"Saving data to JSON file: {filename}")
    try:
        with open(filename, 'w') as f:
            json.dump(data, f)
            print(f"Data saved successfully to {filename}")
    except Exception as e:
        print(f"Error saving data to JSON: {e}")
        raise

def upload_to_s3(filename, bucket_name, s3_filename):
    print(f"Uploading {filename} to S3 bucket {bucket_name} as {s3_filename}")
    s3 = boto3.client('s3', region_name=os.getenv('AWS_DEFAULT_REGION', 'eu-north-1'))
    try:
        s3.upload_file(filename, bucket_name, s3_filename)
        print(f"File uploaded to S3: s3://{bucket_name}/{s3_filename}")
    except FileNotFoundError:
        print(f"Error: The file {filename} was not found")
    except NoCredentialsError:
        print("Error: AWS credentials not available")
    except Exception as e:
        print(f"Error uploading file to S3: {e}")
        raise

def download_from_cloudfront(url):
    print(f"Downloading file from CloudFront URL: {url}")
    try:
        response = requests.get(url)
        print(f"Received response from CloudFront: {response.status_code}")
        if response.status_code == 200:
            print(f"File downloaded successfully from CloudFront")
            return response.content
        else:
            raise Exception(f"Failed to download from CloudFront: {response.status_code}")
    except Exception as e:
        print(f"Error downloading from CloudFront: {e}")
        raise

def main(config_path):
    print(f"Starting main process with config: {config_path}")
    config = load_config(config_path)

    # Extract values from config
    url = config.get('url')
    bucket_name = config.get('bucket_name')
    s3_filename = config.get('s3_filename')
    cloudfront_domain = config.get('cloudfront_domain') or os.getenv('CLOUDFRONT_DOMAIN')
    cloudfront_url = config.get('cloudfront_url') or f"https://{cloudfront_domain}/{s3_filename}"

    print(f"URL: {url}, Bucket: {bucket_name}, S3 Filename: {s3_filename}, CloudFront Domain: {cloudfront_domain}, CloudFront URL: {cloudfront_url}")

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
    else:
        print("Failed to verify the download from CloudFront.")

if __name__ == "__main__":
    config_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), 'config.json')
    main(config_path)
