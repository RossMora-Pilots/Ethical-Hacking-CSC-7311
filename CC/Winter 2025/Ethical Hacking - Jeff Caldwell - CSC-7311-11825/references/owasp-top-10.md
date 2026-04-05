# OWASP Top 10 — Study Companion

> Course deliverable for Week 13 included an OWASP Top 10 writeup. This page is the study companion summarizing the 2021 edition, with examples and mitigations oriented toward the attack surfaces covered in CSC-7311.

The OWASP Top 10 is the most widely referenced web-application risk catalog. It is **not** a checklist — it is a risk ranking updated every few years based on observed prevalence, detectability, and impact. The 2021 edition (current at time of course) reorganized the list significantly from 2017.

---

## A01:2021 — Broken Access Control

**Moved up** from #5 (2017) → #1 (2021) — 94% of tested applications had some form of this.

**What it is:** users can access resources or perform actions outside of their intended permissions.

**Typical examples:**
- Parameter tampering: `GET /api/users/123/details` → change `123` to `124`
- Directory traversal: `GET /download?file=../../../../etc/passwd`
- JWT token not validated (missing / `alg:none`)
- Missing access-control checks on sensitive endpoints
- Force browsing to authenticated pages
- CORS misconfiguration allowing origin spoofing

**Detection techniques:**
- Manual endpoint enumeration → compare authenticated / unauthenticated access
- Burp Suite "match-and-replace" to swap user IDs
- Test every CRUD endpoint: can user A read/modify/delete user B's data?

**Mitigations:**
- Deny by default; explicit allow
- Centralized access control checks
- Log failures, alert on patterns
- Test access control in CI

**Course connection:** Pickle Rick leveraged a web portal with command execution that required no authorization check beyond initial login — exemplifies how simple it is to abuse once authenticated.

---

## A02:2021 — Cryptographic Failures

**Previously:** "Sensitive Data Exposure" (#3 in 2017).

**What it is:** failures related to cryptography — or absence of it — exposing sensitive data.

**Typical examples:**
- Transmitting credentials / session tokens over HTTP
- Storing passwords with MD5 / SHA1 / unsalted hashes
- Weak TLS ciphers (export-grade, RC4, 3DES)
- Hard-coded cryptographic keys in source code
- Failing to encrypt data at rest

**Detection techniques:**
- `testssl.sh` for TLS misconfiguration
- `ssh-audit` for SSH configurations
- Source-code review for hardcoded secrets (gitleaks, trufflehog)
- Traffic inspection for clear-text credentials

**Mitigations:**
- Use current recommendations (argon2 / bcrypt / scrypt for passwords; AES-GCM / ChaCha20-Poly1305 for encryption)
- TLS 1.2 minimum, 1.3 preferred
- Key management via HSMs, cloud KMS, Vault

---

## A03:2021 — Injection

**Includes:** SQL injection, NoSQL injection, ORM injection, LDAP injection, command injection, expression injection.

**What it is:** untrusted input interpreted as code/commands by a downstream interpreter.

**Canonical example (SQL):**
```sql
-- Vulnerable query construction
query = "SELECT * FROM users WHERE username='" + input + "'"

-- Attacker input:
' OR '1'='1

-- Resulting query:
SELECT * FROM users WHERE username='' OR '1'='1'
```

**Canonical example (command):**
```
# Vulnerable endpoint appends user input to shell command
http://target/page?plot=;id

# Executes: something ;id
# Leaks: uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**Detection techniques:**
- SQLMap: `sqlmap -u "http://<target>/page?id=1" --batch --dbs`
- Burp Scanner / OWASP ZAP
- Manual test payloads: `'`, `"`, `)`, `; `, `||`, backtick

**Mitigations:**
- Parameterized queries / prepared statements
- Stored procedures (with care)
- Input validation (allowlist)
- ORM with safe defaults

**Course connection:** Boiler CTF's Sar2HTML 3.2.1 vulnerability is a textbook OS command injection via the `plot=` parameter. Pickle Rick's web panel accepted shell commands directly — intentionally vulnerable for training.

---

## A04:2021 — Insecure Design

**New category in 2021.** Distinguished from A05 (Misconfiguration) and A06 (Components): A04 is about missing threat modeling, missing security requirements in design, and risky business-logic flows.

**What it is:** flaws introduced by design decisions before any code is written.

**Examples:**
- Password reset flow accepting recovery email with no rate limit
- Checkout flow that trusts client-side price values
- Chat system that lets users create channels without a moderation model
- Multi-step workflow missing state validation between steps

**Detection techniques:**
- Threat modeling: STRIDE, DREAD, PASTA
- Abuse case analysis
- Security requirements review
- Protocol flow inspection

**Mitigations:**
- SSDLC with security gates
- Threat modeling during design
- Integration tests for abuse cases
- Clear security requirements per feature

---

## A05:2021 — Security Misconfiguration

**What it is:** insecure defaults, incomplete configurations, overly permissive configurations, verbose error messages, unpatched components.

**Examples:**
- Directory listing enabled on web server
- Default credentials left in place
- Debug endpoints in production (`/debug`, `/trace`, Spring Actuator)
- Verbose error messages leaking stack traces
- Security headers missing (`Content-Security-Policy`, `X-Content-Type-Options`)

**Course connection:** Pickle Rick + Boiler both exposed internal info through `robots.txt`, HTML comments, and log files — textbook misconfiguration exposure.

**Mitigations:**
- Hardening guides (CIS Benchmarks)
- Infrastructure as Code with security checks (tfsec, checkov)
- Automated configuration scanning
- Minimal attack surface (disable unused features)

---

## A06:2021 — Vulnerable & Outdated Components

**Previously:** "Using Components with Known Vulnerabilities" (#9 in 2017).

**What it is:** running software versions with published CVEs.

**Examples:**
- Joomla 3.9.10 (Boiler CTF) — multiple CVEs
- Log4j 2.0–2.14.1 (CVE-2021-44228, Log4Shell)
- Struts 2.3.5–2.3.31 (CVE-2017-5638, Equifax breach)
- jQuery < 3.5.0 (multiple XSS)

**Detection techniques:**
- Dependency scanning: Snyk, OWASP Dependency-Check, Dependabot, Renovate
- JoomScan / WPScan for CMS
- Wappalyzer browser extension
- Nmap service/version detection

**Mitigations:**
- Software Bill of Materials (SBOM)
- Automated patching pipelines
- Version pinning with active maintenance
- Component inventory and EOL tracking

---

## A07:2021 — Identification & Authentication Failures

**Previously:** "Broken Authentication" (#2 in 2017, dropped to #7 as better defaults became common).

**What it is:** flaws in identity / authentication / session management.

**Examples:**
- Credential stuffing against unprotected login
- Weak password policies
- Session IDs in URLs
- Missing MFA
- Credential recovery via known-answerable questions
- No account lockout / rate limiting

**Detection techniques:**
- Hydra / Medusa / Burp Intruder
- Session cookie analysis (entropy, invalidation, Secure/HttpOnly flags)
- Password policy testing

**Mitigations:**
- MFA by default
- Password length requirements (NIST: 8 character minimum, no complexity requirement, check against breach corpora)
- Rate limiting / exponential backoff
- Generic error messages (don't reveal "user exists")
- Session management framework, not custom

---

## A08:2021 — Software & Data Integrity Failures

**New category in 2021.** Covers supply-chain risks and insecure deserialization (which was its own category in 2017, #8).

**What it is:** code and data integrity not validated when they should be.

**Examples:**
- CI/CD pipelines with no integrity checks on dependencies
- Insecure deserialization allowing RCE via crafted objects
- Auto-update mechanisms without signature verification
- npm package takeover
- GitHub action pinned to mutable tag (`v1`) instead of commit SHA

**Notable incidents:**
- SolarWinds (2020)
- event-stream npm package (2018)
- codecov bash uploader (2021)

**Mitigations:**
- Digital signatures on artifacts
- Lockfiles committed and reviewed
- SBOMs with integrity verification
- SLSA framework adoption

---

## A09:2021 — Security Logging & Monitoring Failures

**Previously:** "Insufficient Logging & Monitoring" (#10 in 2017).

**What it is:** attacks are not detected because events aren't captured, aren't forwarded, or aren't analyzed.

**Mitigations:**
- Log authentication events (success + failure)
- Log access control failures
- Log server-side input validation failures
- Centralize logs (SIEM: Wazuh, Splunk, Elastic, Sentinel)
- Establish detection rules + alert on them
- Regular testing of detection coverage (purple teaming)

---

## A10:2021 — Server-Side Request Forgery (SSRF)

**New category.** Split out of broader access control because of cloud-era prevalence.

**What it is:** the server fetches a URL supplied by the attacker, which can be redirected toward internal systems.

**Canonical example (cloud metadata theft):**
```
POST /webhook HTTP/1.1
url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

In AWS: returns IAM role credentials. In Azure / GCP: returns equivalent metadata.

**Mitigations:**
- Allowlist internal URLs, deny by default
- Network segmentation preventing app → metadata service access
- IMDSv2 (AWS requires session token on metadata requests)
- Disable HTTP redirects in URL fetchers

---

## How OWASP Maps to This Course's Labs

| Lab / CTF | OWASP category exploited |
|---|---|
| **Pickle Rick** (Midterm) | A01 Broken Access Control, A03 Injection, A05 Misconfiguration |
| **Mr. Robot CTF** | A07 Auth Failures (WP brute force), A06 Outdated Components |
| **Boiler CTF** (Final) | A03 Injection (Sar2HTML), A05 Misconfiguration (anon FTP), A06 Outdated Components (Joomla 3.9.10) |

---

## Study References

- [OWASP Top 10:2021](https://owasp.org/www-project-top-ten/)
- [OWASP Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) — free, browser-based labs per OWASP category
- [HackTricks](https://book.hacktricks.xyz/) — comprehensive offensive reference

---

_Previous page:_ [Tools](tools.md) · _Back to:_ [README](../README.md)
