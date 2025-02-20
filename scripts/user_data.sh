#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
echo "Hello, My Name is Mawuli, and This is my DR project" > /var/www/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx