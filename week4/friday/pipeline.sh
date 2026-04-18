#!/usr/bin/env bash

set -euo pipefail

echo "=============================="
echo " KijaniKiosk IaC Pipeline"
echo "=============================="

TF_DIR="terraform"
ANSIBLE_DIR="ansible"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"

echo ""
echo "[1/4] Initializing Terraform..."
terraform -chdir=$TF_DIR init

echo ""
echo "[2/4] Applying Terraform..."
terraform -chdir=$TF_DIR apply -auto-approve

echo ""
echo "[3/4] Extracting Terraform outputs..."

API_IP=$(terraform -chdir=$TF_DIR output -raw api_ip)
PAYMENTS_IP=$(terraform -chdir=$TF_DIR output -raw payments_ip)
LOGS_IP=$(terraform -chdir=$TF_DIR output -raw logs_ip)

echo "API IP: $API_IP"
echo "PAYMENTS IP: $PAYMENTS_IP"
echo "LOGS IP: $LOGS_IP"

echo ""
echo "[4/4] Generating Ansible inventory..."

cat > $INVENTORY_FILE <<EOF
[api]
$API_IP

[payments]
$PAYMENTS_IP

[logs]
$LOGS_IP

[kijanikiosk:children]
api
payments
logs

[kijanikiosk:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/kijanikiosk-key.pem
EOF

echo ""
echo "Inventory generated at $INVENTORY_FILE"

echo ""
echo "[5/4] Running Ansible playbook..."

ansible-playbook -i $INVENTORY_FILE $ANSIBLE_DIR/kijanikiosk.yml

echo ""
echo "=============================="
echo " PIPELINE COMPLETED SUCCESSFULLY!"
echo "=============================="