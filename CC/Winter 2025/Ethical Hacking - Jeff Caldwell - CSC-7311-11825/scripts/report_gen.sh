#!/bin/bash
# report_gen.sh — Generate a markdown penetration test report skeleton.
#
# Creates a professional pentest report template with standard sections
# and placeholder text showing expected content for each area.
#
# Usage:
#     ./report_gen.sh <target_name> <output_file>
#     ./report_gen.sh "ACME Corp" report_acme.md
#
# Author: Ross Moravec
# Date:   2025-04

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <target_name> <output_file>" >&2
    exit 1
fi

TARGET="$1"
OUTPUT="$2"

DATE=$(date +%Y-%m-%d)

cat > "$OUTPUT" <<REPORT
# Penetration Test Report — ${TARGET}

**Date:** ${DATE}
**Tester:** Ross Moravec
**Classification:** CONFIDENTIAL

---

## 1. Executive Summary

Provide a high-level overview of the engagement, key risk findings, and
overall security posture. This section is intended for non-technical
stakeholders.

> _Example: During the assessment of ${TARGET}, N critical and N high
> severity vulnerabilities were identified that could allow unauthorized
> access to sensitive data._

## 2. Scope

| Item          | Detail                              |
|---------------|-------------------------------------|
| Target        | ${TARGET}                           |
| IP range      | _e.g., 10.10.10.0/24_              |
| Testing window| _start date – end date_             |
| Type          | _External / Internal / Web App_     |
| Rules of engagement | _link or inline summary_      |

## 3. Methodology

Describe the phases followed during the engagement:

1. **Reconnaissance** — passive and active information gathering.
2. **Scanning & Enumeration** — port scanning, service fingerprinting.
3. **Exploitation** — attempting to leverage discovered vulnerabilities.
4. **Post-Exploitation** — privilege escalation, lateral movement, data access.
5. **Reporting** — documentation of findings and remediation guidance.

## 4. Findings

| # | Title | Severity | CVSS | Affected Asset | Status |
|---|-------|----------|------|----------------|--------|
| 1 | _e.g., SQL Injection in login form_ | Critical | 9.8 | web01 | Open |
| 2 | _e.g., Default credentials on SSH_  | High     | 8.1 | db01  | Open |
| 3 | _e.g., Missing security headers_    | Medium   | 5.3 | web01 | Open |

### 4.1 Finding Detail Template

**Title:** _Vulnerability name_
**Severity:** _Critical / High / Medium / Low / Info_
**CVSS:** _0.0–10.0_
**Affected Asset:** _hostname or IP_

**Description:** _What the vulnerability is and why it matters._

**Evidence:** _Screenshots, command output, or log excerpts._

**Remediation:** _Specific steps to fix or mitigate._

## 5. Remediation Summary

| Priority | Action | Owner | Target Date |
|----------|--------|-------|-------------|
| Critical | _Patch SQL injection in login endpoint_ | Dev team | _YYYY-MM-DD_ |
| High     | _Rotate default SSH credentials_ | Ops team | _YYYY-MM-DD_ |

## 6. Appendix

- **Tool versions:** Nmap X.XX, Burp Suite X.X, Metasploit X.X
- **Wordlists used:** _e.g., rockyou.txt, SecLists/common.txt_
- **Raw scan outputs:** _Attach or link to supplementary files._
REPORT

echo "Report skeleton written to ${OUTPUT}"
