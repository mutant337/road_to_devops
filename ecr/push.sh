#!/bin/bash
# This code build docker image and push it into ecr

ecr="685269275551.dkr.ecr.eu-north-1.amazonaws.com"

aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin $ecr
docker build -t ${ecr}/mutant .
docker push $ecr/mutant
