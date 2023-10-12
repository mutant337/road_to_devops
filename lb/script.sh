#!/bin/bash

secret_value=$(aws secretsmanager get-secret-value --secret-id=my-secret --query SecretString --output text)

echo "SECRET=$secret_value" > /home/ubuntu/road_to_devops/lb/.env

