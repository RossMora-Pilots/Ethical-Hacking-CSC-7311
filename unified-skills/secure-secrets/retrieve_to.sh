#!/usr/bin/env bash
# Retrieve a secret from a provider into a file (no echo). Strict perms. Idempotent.
# Usage: retrieve_to.sh <provider> <name_or_path> <out_path>
# Providers: onepassword|1password|op, aws|aws_sm, ansible|ansible_vault|av

set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <provider> <name_or_path> <out_path>" >&2
  exit 2
fi

provider=$(echo "$1" | tr '[:upper:]' '[:lower:]')
name_or_path="$2"
out="$3"

mkdir -p "$(dirname "$out")"

case "$provider" in
  onepassword|1password|op)
    command -v op >/dev/null 2>&1 || { echo "ERR: op CLI missing" >&2; exit 1; }
    : "${OP_VAULT:?ERR: OP_VAULT not set}"
    : "${OP_SERVICE_ACCOUNT_TOKEN:?ERR: OP_SERVICE_ACCOUNT_TOKEN not set}"
    # Avoid printing value; redirect to out
    op document get "$name_or_path" --vault "$OP_VAULT" > "$out"
    chmod 600 "$out" 2>/dev/null || true
    ;;
  aws|aws_sm)
    SECRET_NAME="$name_or_path"
    region="${AWS_DEFAULT_REGION:-${AWS_REGION:-}}"
    if [ -z "$region" ]; then echo "ERR: AWS region not set" >&2; exit 1; fi
    has_local_aws=0; command -v aws >/dev/null 2>&1 && has_local_aws=1
    has_docker=0; command -v docker >/dev/null 2>&1 && has_docker=1
    # Basic creds check
    if [ -z "${AWS_PROFILE:-}" ] && { [ -z "${AWS_ACCESS_KEY_ID:-}" ] || [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]; }; then
      echo "ERR: AWS credentials not set" >&2; exit 1
    fi
    if [ "$has_local_aws" -eq 1 ]; then
      aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text > "$out"
    elif [ "$has_docker" -eq 1 ]; then
      docker run --rm -i \
        -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_DEFAULT_REGION \
        amazon/aws-cli:latest secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text > "$out"
    else
      echo "ERR: Neither aws nor docker available" >&2; exit 1
    fi
    chmod 600 "$out" 2>/dev/null || true
    ;;
  ansible|ansible_vault|av)
    command -v ansible-vault >/dev/null 2>&1 || { echo "ERR: ansible-vault missing" >&2; exit 1; }
    file_path=""
    if [ -f "$name_or_path" ]; then
      file_path="$name_or_path"
    elif [ -n "${ANSIBLE_VAULT_FILE:-}" ]; then
      file_path="$ANSIBLE_VAULT_FILE"
    else
      echo "ERR: Ansible Vault file not found; pass file path as <name_or_path> or set ANSIBLE_VAULT_FILE" >&2
      exit 1
    fi
    key_path="${ANSIBLE_VAULT_KEY_PATH:-value}"
    if [ -n "${ANSIBLE_VAULT_ID_LABEL:-}" ] && [ -n "${ANSIBLE_VAULT_PASS:-}" ]; then
      if command -v yq >/dev/null 2>&1; then
        ansible-vault view --vault-id "$ANSIBLE_VAULT_ID_LABEL@env:ANSIBLE_VAULT_PASS" "$file_path" | yq -r ".${key_path}" > "$out"
      else
        ansible-vault view --vault-id "$ANSIBLE_VAULT_ID_LABEL@env:ANSIBLE_VAULT_PASS" "$file_path" | sed -n "s/^${key_path}:[[:space:]]*//p" > "$out"
      fi
    elif [ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ] && [ -f "$ANSIBLE_VAULT_PASSWORD_FILE" ]; then
      if command -v yq >/dev/null 2>&1; then
        ansible-vault view --vault-password-file="$ANSIBLE_VAULT_PASSWORD_FILE" "$file_path" | yq -r ".${key_path}" > "$out"
      else
        ansible-vault view --vault-password-file="$ANSIBLE_VAULT_PASSWORD_FILE" "$file_path" | sed -n "s/^${key_path}:[[:space:]]*//p" > "$out"
      fi
    else
      echo "ERR: Neither ANSIBLE_VAULT_ID_LABEL/ANSIBLE_VAULT_PASS nor ANSIBLE_VAULT_PASSWORD_FILE set" >&2
      exit 1
    fi
    chmod 600 "$out" 2>/dev/null || true
    ;;
  *)
    echo "ERR: Unknown provider '$provider'" >&2
    exit 2
    ;;
esac

echo "OK:$provider:$name_or_path:$out" > /dev/null

