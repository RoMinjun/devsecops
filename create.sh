#!/bin/bash
set -e

REGION="us-east-1"
KEY_NAME=${1:-vockey}

aws cloudformation create-stack --stack-name k3s-vpc --template-body file://k3s-vpc.yml --region "$REGION"
aws cloudformation wait stack-create-complete --stack-name k3s-vpc --region "$REGION"

# Master stack (exports SG + master IP)
aws cloudformation create-stack --stack-name k3s-master \
  --capabilities CAPABILITY_IAM \
  --template-body file://master.yml \
  --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
  --region "$REGION"
aws cloudformation wait stack-create-complete --stack-name k3s-master --region "$REGION"

# Worker stack (imports master exports)
aws cloudformation create-stack --stack-name k3s-worker \
  --capabilities CAPABILITY_IAM \
  --template-body file://worker.yml \
  --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
  --region "$REGION"
aws cloudformation wait stack-create-complete --stack-name k3s-worker --region "$REGION"
