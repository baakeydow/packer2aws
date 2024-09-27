#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <AMI_ID>"
    exit 1
fi

if [ -z "$AWS_OWNER_ID" ]; then
  echo "Error: AWS_OWNER_ID environment variable is not set."
  exit 1
fi

AMI_ID=$1

# Deregister the AMI
echo "Deregistering AMI: $AMI_ID"
aws ec2 deregister-image --image-id $AMI_ID

# Get a list of snapshots associated with the AMI
echo "Retrieving associated snapshots..."
SNAPSHOT_IDS=$(aws ec2 describe-snapshots --filters Name=owner-id,Values=$AWS_OWNER_ID Name=description,Values="*${AMI_ID}*" --query 'Snapshots[*].SnapshotId' --output text)

# Check if there are snapshots to delete
if [ -z "$SNAPSHOT_IDS" ]; then
  echo "No snapshots found associated with AMI: $AMI_ID"
else
  # Delete each snapshot
  for SNAP_ID in $SNAPSHOT_IDS; do
    echo "Deleting snapshot: $SNAP_ID"
    aws ec2 delete-snapshot --snapshot-id $SNAP_ID
  done
fi

echo "Process completed."
