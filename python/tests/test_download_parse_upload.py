import unittest
from src.download_parse_upload import filter_products

class TestDownloadParseUpload(unittest.TestCase):

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

if __name__ == "__main__":
    unittest.main()
