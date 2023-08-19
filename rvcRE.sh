#!/bin/bash
# Exit on error
set -e

# Activate the virtual environment
echo "Activating virtual environment"
source rvc/bin/activate

# Navigate to the project directory if not already in it
echo "Navigating to the directory"
cd Retrieval-based-Voice-Conversion-WebUI || { echo "Could not navigate to directory. Exiting script."; exit 1; }

# Launch the application
echo "Launching the application"
python infer-web.py