#!/bin/bash

# Define the output file
output_file="dor_checkpoint_project_code.txt"

# Start with a clean output file
echo "Gathering all project files into $output_file"
echo "" > $output_file

# Function to gather code from a directory, excluding `terragrunt-cache` directories
gather_code() {
    local dir_path=$1
    for file in $(find $dir_path -type f ! -path "*/.terragrunt-cache/*"); do
        echo "Processing $file"
        echo "" >> $output_file
        echo "==================================================" >> $output_file
        echo "File: $file" >> $output_file
        echo "==================================================" >> $output_file
        echo "" >> $output_file
        cat $file >> $output_file
        echo "" >> $output_file
    done
}

# Call the function with the root project directory
gather_code "."

echo "All files have been gathered into $output_file"
