#!/bin/bash -x
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

echo "Disabling Destination Check"
aws ec2 modify-instance-attribute --no-source-dest-check \
  --region "$REGION" \
  --instance-id "$INSTANCE_ID"

echo "Searching for ENI identifier in the current AZ ($AZ)..."
ENI_ID=$(aws ec2 describe-network-interfaces \
  --region "$REGION" \
  --filters "Name=tag:Purpose,Values=NATInstance" "Name=availability-zone,Values=$AZ" \
  --query NetworkInterfaces[0].NetworkInterfaceId --output text
)

if [ "$ENI_ID" != "None" ]; then
  echo "Detected ENI with ID -> $ENI_ID. Trying to attach..."
    # attach the ENI
  aws ec2 attach-network-interface \
    --region "$REGION" \
    --instance-id "$INSTANCE_ID" \
    --device-index 1 \
    --network-interface-id "$ENI_ID"
else
  echo "ENI not found!"
fi

# start SNAT
systemctl enable snat
systemctl start snat
