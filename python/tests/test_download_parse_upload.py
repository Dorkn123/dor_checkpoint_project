import unittest
from unittest.mock import patch, mock_open, MagicMock
from src.download_parse_upload import load_config, filter_products, upload_to_s3, download_from_cloudfront

class TestDownloadParseUpload(unittest.TestCase):

    @patch('builtins.open', new_callable=mock_open, read_data='{"url": "http://example.com", "bucket_name": "test-bucket", "s3_filename": "test.json", "cloudfront_url": "http://cloudfront.example.com"}')
    def test_load_config(self, mock_file):
        config = load_config("dummy_path")
        self.assertEqual(config['url'], "http://example.com")

    def test_filter_products(self):
        data = {
            "products": [
                {"id": 1, "title": "Cheap Product", "price": 50},
                {"id": 2, "title": "Expensive Product", "price": 150}
            ]
        }
        expected_result = {
            "products": [
                {"id": 2, "title": "Expensive Product", "price": 150}
            ]
        }
        result = filter_products(data, min_price=100)
        self.assertEqual(result, expected_result)

    @patch('boto3.client')
    def test_upload_to_s3(self, mock_boto_client):
        mock_s3 = MagicMock()
        mock_boto_client.return_value = mock_s3
        upload_to_s3("test.json", "test-bucket", "test.json")
        mock_s3.upload_file.assert_called_with("test.json", "test-bucket", "test.json")

    @patch('requests.get')
    def test_download_from_cloudfront(self, mock_get):
        mock_response = MagicMock()
        mock_response.content = b'Some content'
        mock_response.status_code = 200
        mock_get.return_value = mock_response

        content = download_from_cloudfront("http://cloudfront.example.com")
        self.assertEqual(content, b'Some content')

if __name__ == "__main__":
    unittest.main()
