#!/bin/bash
set -e

REGION="us-east-1"

aws cloudformation delete-stack --stack-name k3s-cluster --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name k3s-cluster --region "$REGION"

aws cloudformation delete-stack --stack-name k3s-vpc --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name k3s-vpc --region "$REGION"