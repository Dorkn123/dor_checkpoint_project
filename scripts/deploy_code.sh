#!/bin/bash

# Install Python dependencies
pip install -r python/requirements.txt

# Run the Python script
python3 python/src/download_parse_upload.py
