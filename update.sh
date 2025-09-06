#!/bin/bash
set -e

# Usage: ./update.sh [KEY_NAME]
# Environment: set REGION to override default region

REGION=${REGION:-us-east-1}
KEY_NAME=${1:-vockey}

echo "Updating k3s-worker stack in region $REGION (KeyName=$KEY_NAME)"

# Attempt update; handle the "No updates are to be performed" case gracefully
set +e
OUTPUT=$(aws cloudformation update-stack \
  --stack-name k3s-worker \
  --capabilities CAPABILITY_IAM \
  --template-body file://worker.yml \
  --parameters ParameterKey=KeyName,ParameterValue="$KEY_NAME" \
  --region "$REGION" 2>&1)
STATUS=$?
set -e

if [ $STATUS -ne 0 ]; then
  if echo "$OUTPUT" | grep -q "No updates are to be performed"; then
    echo "No updates to perform."
    exit 0
  else
    echo "$OUTPUT"
    exit $STATUS
  fi
fi

echo "Update started; waiting for completion..."
aws cloudformation wait stack-update-complete --stack-name k3s-worker --region "$REGION"
echo "Update completed successfully."

