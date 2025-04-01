#!/bin/bash
# Update package list and install Git and Python 3
apt-get update -y
apt-get install -y git python3 python3-pip

# Clone your FastAPI app repository from GitHub
cd /home/ubuntu
git clone https://github.com/MawuliB/dr_app.git
cd dr_app

# Install dependencies (assuming requirements.txt is in the repo)
pip3 install -r requirements.txt

# Export environment variables (you can inject these via launch template or user data)
echo "export PRIMARY_S3_URL=<PRIMARY_BUCKET_URL>" >> /etc/environment
echo "export DR_S3_URL=<SECONDARY_BUCKET_URL>" >> /etc/environment
echo "export PRIMARY_RDS_ENDPOINT=<PRIMARY_DB_ENDPOINT>" >> /etc/environment
echo "export DR_RDS_ENDPOINT=<SECONDARY_DB_ENDPOINT>" >> /etc/environment
echo "export USE_DR=<USE_DR>" >> /etc/environment

# Reload environment variables
source /etc/environment

# Start the FastAPI app using uvicorn in the background
nohup uvicorn app:app --host 0.0.0.0 --port 80 > app.log 2>&1 &
