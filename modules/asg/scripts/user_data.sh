#!/bin/bash
set -e  # Exit on any error

# Update and install necessary packages
sudo apt-get update -y
sudo apt-get install -y git python3 python3-pip python3-venv

# Navigate to home directory
cd /home/ubuntu

# Clone the app repo only if it doesn't exist
if [ ! -d "/home/ubuntu/dr_app" ]; then
    git clone https://github.com/MawuliB/dr_app.git /home/ubuntu/dr_app
fi

cd dr_app

# Create virtual environment and activate it
python3 -m venv /home/ubuntu/dr_venv
source /home/ubuntu/dr_venv/bin/activate

# Install dependencies inside the virtual environment
pip install -r requirements.txt
pip install uvicorn

# Export environment variables
echo "export PRIMARY_S3_URL=${PRIMARY_BUCKET_URL}" | sudo tee -a /etc/environment
echo "export DR_S3_URL=${SECONDARY_BUCKET_URL}" | sudo tee -a /etc/environment
echo "export PRIMARY_RDS_ENDPOINT=${PRIMARY_DB_ENDPOINT}" | sudo tee -a /etc/environment
echo "export DR_RDS_ENDPOINT=${SECONDARY_DB_ENDPOINT}" | sudo tee -a /etc/environment
echo "export USE_DR=${USE_DR}" | sudo tee -a /etc/environment

# Reload environment variables
source /etc/environment

# Create a log file and set permissions
if [ ! -f "/home/ubuntu/dr_app/app.log" ]; then
    touch /home/ubuntu/dr_app/app.log
fi
# Set ownership and permissions for the log file
sudo chown ubuntu:ubuntu /home/ubuntu/dr_app/app.log
sudo chmod 666 /home/ubuntu/dr_app/app.log

# Run the FastAPI app in the background
sudo nohup /home/ubuntu/dr_venv/bin/uvicorn app:app --host 0.0.0.0 --port 80 > app.log 2>&1 &
