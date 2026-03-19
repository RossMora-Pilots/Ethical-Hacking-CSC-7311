#!/usr/bin/env bash
# Save a plaintext secret to 1Password, AWS Secrets Manager, and Ansible Vault (idempotent).
# Uses AGENTS.md patterns. Never echoes secret values. Verifies via hash/trim compare.

set -euo pipefail

SECRET_NAME="${SECRET_NAME:-gitlab/mirror-ccpm/pat}"
SECRET_SRC_FILE="${SECRET_SRC_FILE:-$HOME/.ccpm/secrets/gitlab-pat}"

if [ ! -f "$SECRET_SRC_FILE" ]; then
  echo "SRC_MISSING:$SECRET_SRC_FILE" >&2
  exit 1
fi

trim_file() { tr -d '\r\n' < "$1"; }

src_trim=$(trim_file "$SECRET_SRC_FILE")

results=()

# 1Password — Save (delete-then-create, document from stdin)
if command -v op >/dev/null 2>&1 && [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ] && [ -n "${OP_VAULT:-}" ]; then
  OP_ITEM_TITLE="${OP_ITEM_TITLE:-$SECRET_NAME}"
  OP_ITEM_ID=$(op item get "$OP_ITEM_TITLE" --vault "$OP_VAULT" --format json 2>/dev/null | jq -r '.id // empty' || true)
  if [ -n "${OP_ITEM_ID:-}" ]; then op item delete "$OP_ITEM_ID" --vault "$OP_VAULT" >/dev/null; fi
  cat "$SECRET_SRC_FILE" | op document create - --title "$OP_ITEM_TITLE" --file-name "$(basename "$SECRET_SRC_FILE")" --vault "$OP_VAULT" >/dev/null
  tmp_op=$(mktemp)
  op document get "$OP_ITEM_TITLE" --vault "$OP_VAULT" > "$tmp_op"
  [ "$(trim_file "$tmp_op")" = "$src_trim" ] && results+=("OP_SAVE:OK:$OP_VAULT:$OP_ITEM_TITLE") || results+=("OP_VERIFY:DIFF")
  rm -f "$tmp_op"
else
  results+=("OP_SAVE:SKIP_ENV_OR_CLI")
fi

# AWS Secrets Manager — Save or Update (prefer local aws; fallback docker)
aws_ok=0
region="${AWS_DEFAULT_REGION:-${AWS_REGION:-}}"
has_local_aws=0; command -v aws >/dev/null 2>&1 && has_local_aws=1
has_docker=0; command -v docker >/dev/null 2>&1 && has_docker=1
if [ -n "$region" ] && { [ -n "${AWS_PROFILE:-}" ] || { [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; }; }; then
  if [ "$has_local_aws" -eq 1 ]; then
    if ! aws secretsmanager describe-secret --secret-id "$SECRET_NAME" >/dev/null 2>&1; then
      aws secretsmanager create-secret --name "$SECRET_NAME" --secret-string "$(cat "$SECRET_SRC_FILE")" >/dev/null
      results+=("AWS_CREATE:OK:$region:$SECRET_NAME")
    else
      aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" --secret-string "$(cat "$SECRET_SRC_FILE")" >/dev/null
      results+=("AWS_PUT:OK:$region:$SECRET_NAME")
    fi
    tmp_aws=$(mktemp)
    aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text > "$tmp_aws"
    [ "$(trim_file "$tmp_aws")" = "$src_trim" ] && results+=("AWS_VERIFY:MATCH") || results+=("AWS_VERIFY:DIFF")
    rm -f "$tmp_aws"
    aws_ok=1
  elif [ "$has_docker" -eq 1 ]; then
    envargs=(-e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_DEFAULT_REGION)
    if docker run --rm "${envargs[@]}" amazon/aws-cli:latest secretsmanager describe-secret --secret-id "$SECRET_NAME" >/dev/null 2>&1; then
      docker run --rm "${envargs[@]}" amazon/aws-cli:latest secretsmanager put-secret-value --secret-id "$SECRET_NAME" --secret-string "$(cat "$SECRET_SRC_FILE")" >/dev/null
      results+=("AWS_PUT:OK:$region:$SECRET_NAME")
    else
      docker run --rm "${envargs[@]}" amazon/aws-cli:latest secretsmanager create-secret --name "$SECRET_NAME" --secret-string "$(cat "$SECRET_SRC_FILE")" >/dev/null
      results+=("AWS_CREATE:OK:$region:$SECRET_NAME")
    fi
    tmp_aws=$(mktemp)
    docker run --rm "${envargs[@]}" amazon/aws-cli:latest secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text > "$tmp_aws"
    [ "$(trim_file "$tmp_aws")" = "$src_trim" ] && results+=("AWS_VERIFY:MATCH") || results+=("AWS_VERIFY:DIFF")
    rm -f "$tmp_aws"
    aws_ok=1
  fi
else
  results+=("AWS_SAVE:SKIP_ENV")
fi
if [ "$aws_ok" -ne 1 ]; then results+=("AWS_SAVE:SKIPPED_NO_CLI"); fi

# Ansible Vault — Save to ANSIBLE_VAULT_FILE using temp YAML value key
av_ok=0
ANSIBLE_VAULT_FILE="${ANSIBLE_VAULT_FILE:-secrets/${SECRET_NAME//\//-}.vault.yml}"
mkdir -p "$(dirname "$ANSIBLE_VAULT_FILE")"
if command -v ansible-vault >/dev/null 2>&1; then
  tmp_yaml=$(mktemp)
  printf 'value: %s\n' "$(cat "$SECRET_SRC_FILE")" > "$tmp_yaml"
  if [ -n "${ANSIBLE_VAULT_ID_LABEL:-}" ] && [ -n "${ANSIBLE_VAULT_PASS:-}" ]; then
    ansible-vault encrypt --vault-id "$ANSIBLE_VAULT_ID_LABEL@env:ANSIBLE_VAULT_PASS" --output "$ANSIBLE_VAULT_FILE" "$tmp_yaml" >/dev/null
    av_ok=1
  elif [ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ] && [ -f "${ANSIBLE_VAULT_PASSWORD_FILE}" ]; then
    vault_id_label="${ANSIBLE_VAULT_ID_LABEL:-default}"
    ansible-vault encrypt --encrypt-vault-id "$vault_id_label" --vault-password-file="$ANSIBLE_VAULT_PASSWORD_FILE" --output "$ANSIBLE_VAULT_FILE" "$tmp_yaml" >/dev/null
    av_ok=1
  else
    results+=("AV_SAVE:SKIP_ENV")
  fi
  shred -u "$tmp_yaml" 2>/dev/null || rm -f "$tmp_yaml"
  if [ "$av_ok" -eq 1 ]; then
    tmp_out=$(mktemp)
    if [ -n "${ANSIBLE_VAULT_ID_LABEL:-}" ] && [ -n "${ANSIBLE_VAULT_PASS:-}" ]; then
      if command -v yq >/dev/null 2>&1; then
        ansible-vault view --vault-id "$ANSIBLE_VAULT_ID_LABEL@env:ANSIBLE_VAULT_PASS" "$ANSIBLE_VAULT_FILE" | yq -r '.value' > "$tmp_out"
      else
        ansible-vault view --vault-id "$ANSIBLE_VAULT_ID_LABEL@env:ANSIBLE_VAULT_PASS" "$ANSIBLE_VAULT_FILE" | sed -n 's/^value:[[:space:]]*//p' > "$tmp_out"
      fi
    else
      if command -v yq >/dev/null 2>&1; then
        ansible-vault view --vault-password-file="$ANSIBLE_VAULT_PASSWORD_FILE" "$ANSIBLE_VAULT_FILE" | yq -r '.value' > "$tmp_out"
      else
        ansible-vault view --vault-password-file="$ANSIBLE_VAULT_PASSWORD_FILE" "$ANSIBLE_VAULT_FILE" | sed -n 's/^value:[[:space:]]*//p' > "$tmp_out"
      fi
    fi
    [ "$(trim_file "$tmp_out")" = "$src_trim" ] && results+=("AV_VERIFY:MATCH:$ANSIBLE_VAULT_FILE") || results+=("AV_VERIFY:DIFF")
    rm -f "$tmp_out"
  fi
else
  results+=("AV_SAVE:SKIP_NO_CLI")
fi

printf '%s\n' "${results[@]}"
