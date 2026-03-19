#!/usr/bin/env bash
# Bootstrap retrieval of the GitLab PAT into ~/.ccpm/secrets/gitlab-pat for use by mirror/askpass.
# Non-interactive; tries preferred provider or falls back in order.
# Env:
#   PREFERRED_PROVIDER or MIRROR_PAT_PROVIDER: onepassword|aws|ansible (optional)
#   SECRET_NAME: logical name (default: gitlab/mirror-ccpm/pat)
#   OUT_FILE: default: $HOME/.ccpm/secrets/gitlab-pat
#   For ansible: ANSIBLE_VAULT_FILE or default /mnt/e/secrets/gitlab-mirror-ccpm.pat.vault.yml

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RETRIEVER="$HERE/retrieve_to.sh"
[ -x "$RETRIEVER" ] || { echo "ERR: retrieve_to.sh not found" >&2; exit 1; }

SECRET_NAME="${SECRET_NAME:-gitlab/mirror-ccpm/pat}"
OUT_FILE="${OUT_FILE:-$HOME/.ccpm/secrets/gitlab-pat}"
mkdir -p "$(dirname "$OUT_FILE")"

normalize() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

# Provide sensible Ansible Vault defaults for Codex CLI automation
AV_FILE_DEFAULT="/mnt/e/secrets/gitlab-mirror-ccpm.pat.vault.yml"
AV_PASS_DEFAULT="/mnt/e/home-vault-system/ansible-vault/vault-pass.sh"
[ -z "${ANSIBLE_VAULT_FILE:-}" ] && [ -f "$AV_FILE_DEFAULT" ] && export ANSIBLE_VAULT_FILE="$AV_FILE_DEFAULT"
[ -z "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ] && [ -f "$AV_PASS_DEFAULT" ] && export ANSIBLE_VAULT_PASSWORD_FILE="$AV_PASS_DEFAULT"

order=()
if [ -n "${PREFERRED_PROVIDER:-${MIRROR_PAT_PROVIDER:-}}" ]; then
  order+=("$(normalize "${PREFERRED_PROVIDER:-$MIRROR_PAT_PROVIDER}")")
fi
# Append defaults with Ansible first for Codex automation
order+=(ansible onepassword aws)
# Deduplicate while preserving order
seen=""; dedup=()
for p in "${order[@]}"; do
  case "$seen" in *"|$p|"*) : ;; *) dedup+=("$p"); seen="${seen}|$p|" ;; esac
done

errors=()
for provider in "${dedup[@]}"; do
  case "$provider" in
    onepassword|1password|op)
      if [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ] && [ -n "${OP_VAULT:-}" ] && command -v op >/dev/null 2>&1; then
        if "$RETRIEVER" onepassword "$SECRET_NAME" "$OUT_FILE" >/dev/null 2>&1; then
          chmod 600 "$OUT_FILE" 2>/dev/null || true
          echo "BOOTSTRAP:OK:onepassword:$SECRET_NAME:$OUT_FILE"
          exit 0
        else
          errors+=("op_retrieve_failed")
        fi
      else
        errors+=("op_env_or_cli_missing")
      fi
      ;;
    aws|aws_sm)
      region="${AWS_DEFAULT_REGION:-${AWS_REGION:-}}"
      have_creds=$([ -n "${AWS_PROFILE:-}" ] || { [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; } && echo 1 || echo 0)
      if [ -n "$region" ] && [ "$have_creds" -eq 1 ] && { command -v aws >/dev/null 2>&1 || command -v docker >/dev/null 2>&1; }; then
        if "$RETRIEVER" aws "$SECRET_NAME" "$OUT_FILE" >/dev/null 2>&1; then
          chmod 600 "$OUT_FILE" 2>/dev/null || true
          echo "BOOTSTRAP:OK:aws:$SECRET_NAME:$OUT_FILE"
          exit 0
        else
          errors+=("aws_retrieve_failed")
        fi
      else
        errors+=("aws_env_or_cli_missing")
      fi
      ;;
    ansible|ansible_vault|av)
      av_file_default="/mnt/e/secrets/gitlab-mirror-ccpm.pat.vault.yml"
      av_path="${ANSIBLE_VAULT_FILE:-$av_file_default}"
      if [ -f "$av_path" ] && command -v ansible-vault >/dev/null 2>&1; then
        if [ -n "${ANSIBLE_VAULT_ID_LABEL:-}" ] && [ -n "${ANSIBLE_VAULT_PASS:-}" ] || [ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ]; then
          if "$RETRIEVER" ansible "$av_path" "$OUT_FILE" >/dev/null 2>&1; then
            chmod 600 "$OUT_FILE" 2>/dev/null || true
            echo "BOOTSTRAP:OK:ansible:$av_path:$OUT_FILE"
            exit 0
          else
            errors+=("ansible_retrieve_failed")
          fi
        else
          errors+=("ansible_auth_missing")
        fi
      else
        errors+=("ansible_file_or_cli_missing")
      fi
      ;;
    *) : ;;
  esac
done

echo "BOOTSTRAP:FAIL:$(IFS=,; echo "${errors[*]}")" >&2
exit 2
