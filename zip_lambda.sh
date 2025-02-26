#!/bin/bash
# Navigate to the lambda code directory
cd modules/lambda/code || exit

# Create a zip file containing failover.py
zip -j ./failover.zip failover.py

echo "Lambda package created at modules/lambda/code/failover.zip"
