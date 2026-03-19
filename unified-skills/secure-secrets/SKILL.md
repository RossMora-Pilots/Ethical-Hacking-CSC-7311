# Skill: Secure Secrets Retrieval

## Description
Retrieves secrets (API keys, tokens, passwords) from secure storage (Ansible Vault, 1Password, AWS Secrets Manager) without printing them to the console.

## Usage
Use this skill when you need to:
- Get a GitHub Personal Access Token (PAT).
- Retrieve an API key for a script.
- Verify a secret exists.

## Tools
### `retrieve_to.sh`
Retrieves a secret to a specific file path.
```bash
./retrieve_to.sh <provider> <secret_name> <output_file>
```
- **provider**: `ansible` (default), `op` (1Password), `aws` (AWS Secrets Manager).
- **secret_name**: The name of the secret (e.g., `gitlab-pat`, `openai-key`).
- **output_file**: Path to write the secret to (e.g., `~/.ccpm/secrets/my-key`).

### `save_all.sh`
Saves a secret to all configured providers (idempotent).
```bash
SECRET_NAME="my/secret" SECRET_SRC_FILE="/path/to/plaintext" ./save_all.sh
```

### `verify_match.sh`
Verifies that a stored secret matches a local file (by hash) without revealing content.
```bash
./verify_match.sh <provider> <secret_name> <local_file>
```

## Examples
**Retrieve GitHub Token:**
```bash
./retrieve_to.sh ansible gitlab-pat ~/.ccpm/secrets/gitlab-pat
export GH_TOKEN=$(cat ~/.ccpm/secrets/gitlab-pat)
```
