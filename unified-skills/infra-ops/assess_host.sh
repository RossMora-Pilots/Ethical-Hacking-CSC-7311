#!/bin/bash
set -euo pipefail

# Configuration
VCENTER_HOST="192.168.0.57"
TARGET_HOST_IP="192.168.0.47"
VAULT_FILE="/mnt/e/home-vault-system/ansible-vault/esxi-vault-ha-credentials.yml"
PASS_FILE="/mnt/e/home-vault-system/ansible-vault/vault-pass.sh"

# 1. Retrieve Credentials
echo "Retrieving credentials..."
export ANSIBLE_VAULT_PASSWORD_FILE="$PASS_FILE"
export ANSIBLE_VAULT_KEY_PATH="."
CREDS_FILE=$(mktemp)
bash /mnt/e/pilots/002-Secrets/scripts/secrets/retrieve_to.sh ansible "$VAULT_FILE" "$CREDS_FILE" >/dev/null

VC_USER=$(grep "vcenter_username:" "$CREDS_FILE" | cut -d' ' -f2)
VC_PASS=$(grep "vcenter_password:" "$CREDS_FILE" | cut -d'"' -f2)
rm "$CREDS_FILE"

# 2. Authenticate
echo "Authenticating to vCenter..."
SESSION_ID=$(curl -k -s -X POST -u "$VC_USER:$VC_PASS" "https://$VCENTER_HOST/rest/com/vmware/cis/session" | jq -r .value)

if [ "$SESSION_ID" == "null" ] || [ -z "$SESSION_ID" ]; then
    echo "Error: Authentication failed."
    exit 1
fi
echo "Authenticated."

# 3. Get Host Status
echo "Checking host status for $TARGET_HOST_IP..."
HOST_INFO=$(curl -k -s -X GET -H "vmware-api-session-id: $SESSION_ID" "https://$VCENTER_HOST/rest/vcenter/host" | jq -r ".value[] | select(.name == \"$TARGET_HOST_IP\")")

if [ -z "$HOST_INFO" ]; then
    echo "Error: Host $TARGET_HOST_IP not found."
    exit 1
fi

HOST_ID=$(echo "$HOST_INFO" | jq -r .host)
CONN_STATE=$(echo "$HOST_INFO" | jq -r .connection_state)
POWER_STATE=$(echo "$HOST_INFO" | jq -r .power_state)

echo "Host ID: $HOST_ID"
echo "Connection State: $CONN_STATE"
echo "Power State: $POWER_STATE"

# 4. List VMs on Host
echo "Listing VMs on host..."
VMS=$(curl -k -s -X GET -H "vmware-api-session-id: $SESSION_ID" "https://$VCENTER_HOST/rest/vcenter/vm?filter.hosts=$HOST_ID")
VM_COUNT=$(echo "$VMS" | jq '.value | length')

echo "VM Count: $VM_COUNT"
if [ "$VM_COUNT" -gt 0 ]; then
    echo "VMs:"
    echo "$VMS" | jq -r '.value[] | "- \(.name) (\(.power_state))"'
fi

# 5. Cleanup Session (Logout)
# curl -k -X DELETE -H "vmware-api-session-id: $SESSION_ID" "https://$VCENTER_HOST/rest/com/vmware/cis/session"
