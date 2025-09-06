#!/bin/bash
set -e

REGION="us-east-1"
KEY_NAME=${1:-vockey}

aws cloudformation create-stack --stack-name k3s-vpc --template-body file://k3s-vpc.yml --region "$REGION"
aws cloudformation wait stack-create-complete --stack-name k3s-vpc --region "$REGION"

aws cloudformation create-stack --stack-name k3s-cluster \
  --capabilities CAPABILITY_IAM \
  --template-body file://k3s-cluster.yml \
  --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
  --region "$REGION"
aws cloudformation wait stack-create-complete --stack-name k3s-cluster --region "$REGION"