#!/bin/bash -x

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

disableDestinationCheck() {
  aws ec2 modify-instance-attribute --no-source-dest-check \
    --region "$REGION" \
    --instance-id "$INSTANCE_ID"
}

checkENI() {
  local filter=("$@")
  local eni_id #Declated separately to avoid masking

  eni_id=$(aws ec2 describe-network-interfaces \
    --region "$REGION" \
    --filters "$${filter[@]}" \
    --query NetworkInterfaces[0].NetworkInterfaceId --output text)
  echo "$eni_id"
}

attachENI() {
  local availability_filter=("Name=tag:Purpose,Values=NATInstance" "Name=availability-zone,Values=$AZ" "Name=status,Values=available")
  ENI_ID=$(checkENI "$${availability_filter[@]}")

  if [ "$ENI_ID" != "None" ]; then
    echo ">>>> Detected ENI with ID -> $ENI_ID. Trying to attach..."
      # attach the ENI
    aws ec2 attach-network-interface \
      --region "$REGION" \
      --instance-id "$INSTANCE_ID" \
      --device-index 1 \
      --network-interface-id "$ENI_ID"
    echo ">>>> ENI with ID ($ENI_ID) attached successfully."
  else
    echo ">>>> Checking if already attached..."
    local is_attached_already_filter=("Name=tag:Purpose,Values=NATInstance" "Name=attachment.instance-id,Values=$INSTANCE_ID")
    ENI_ID=$(checkENI "$${is_attached_already_filter[@]}")
  fi
}

echo "[1] Disabling Destination Check"
disableDestinationCheck

ENI_ID=None
echo "[2] Attaching ENI"
while [ "$ENI_ID" == "None" ]; do
  sleep 5
  attachENI
done

# start SNAT
echo "[3] Starting SNAT service"
systemctl enable snat
systemctl start snat
