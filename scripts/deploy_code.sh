#!/bin/bash
set -e

# Set the deployment environment (default to 'dev' if not provided)
ENVIRONMENT="${ENVIRONMENT:-dev}"
CONFIG_FILE="python/src/config.json"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Install Python dependencies
install_dependencies() {
    log "Installing Python dependencies..."
    if [ -f "python/requirements.txt" ]; then
        pip install -r python/requirements.txt
    else
        log "Error: requirements.txt not found."
        exit 1
    fi
}

# Run the Python script
run_python_script() {
    log "Running the Python script with config: $CONFIG_FILE"
    python3 python/src/download_parse_upload.py "$CONFIG_FILE"

    # Check if the Python script completed successfully
    if [ $? -eq 0 ]; then
        log "Python script executed successfully."
    else
        log "Python script failed."
        exit 1
    fi
}

main() {
    install_dependencies
    run_python_script
}

main
