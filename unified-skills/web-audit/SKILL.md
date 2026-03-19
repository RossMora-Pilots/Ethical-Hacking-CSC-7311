# Skill: Web Audit

## Description
Performs standardized web scanning, header analysis, and report generation for target domains.

## Usage
Use this skill when you need to:
- Scan a website for security headers.
- Check for open ports or TLS issues.
- Generate a summary report of a web property.

## Tools
### `webscan.py`
Python-based scanner that checks headers, redirects, and basic security posture.
```bash
python3 webscan.py --domain <domain> --out <output_file>
```

### `run.ps1`
PowerShell wrapper for the scanning workflow.
```powershell
pwsh run.ps1 -Domain <domain>
```

## Examples
**Scan a domain:**
```bash
python3 webscan.py --domain example.com --out report.json
```
