# Penetration Testing Methodology

## Why a methodology matters

> "If you're just lone-gunning it, doing it whatever order you want, maybe you'll miss something." — J. Caldwell, Week 1

Penetration testing without a framework produces **inconsistent, unrepeatable, unverifiable** work. A methodology:

1. Ensures **consistency** across engagements — Client A gets the same rigour as Client B.
2. Enables **repeatability** — a second tester can verify the first tester's findings.
3. Provides **verifiability** — stakeholders can audit the process, not just the outcome.
4. Prevents **gap coverage** — you don't forget to check obvious things because you were excited about the interesting thing.

The course focused on the **Cyber Kill Chain** and **MITRE ATT&CK** as primary frameworks, with nods to PTES (Penetration Testing Execution Standard) and OSSTMM (Open Source Security Testing Methodology Manual).

## The Six-Phase Lifecycle

This is the applied methodology followed in every course lab and both CTFs.

### Phase 1 — Reconnaissance & Footprinting

**Goal:** gather information about the target *before* touching it.

| Activity | Example |
|---|---|
| Passive OSINT | WHOIS records; LinkedIn; GitHub; social media; news coverage |
| DNS enumeration | `dig`, `nslookup`, subdomain brute-force |
| Infrastructure mapping | Shodan, Censys, certificate transparency logs |
| Personnel intelligence | Email format discovery, leaked credentials, organizational charts |
| Document metadata | Author fields, internal paths in PDF/Office metadata |

**Output:** a target profile — IP ranges, domain names, services believed to be exposed, employees of interest, prior breach exposure.

### Phase 2 — Scanning & Enumeration

**Goal:** identify which systems are reachable, what services they run, what versions they run, and what that version history implies.

| Activity | Tool(s) |
|---|---|
| Port scanning | `nmap -sS -p-` |
| Service/version detection | `nmap -sV` |
| Banner grabbing | `nc`, `curl -I`, `nmap -sV` |
| Default-script probing | `nmap -sC` |
| Vulnerability scanning | OpenVAS, Nessus, Nuclei |
| Directory brute-forcing | `gobuster dir`, `dirb`, `ffuf` |
| CMS-specific enumeration | JoomScan, WPScan, droopescan |
| Application-specific probing | Burp Suite, manual browsing |

**Output:** a vulnerability inventory — candidate targets with confidence levels.

**Key insight from class:** anonymous FTP, hidden `/robots.txt` entries, HTML source comments, and log files regularly leak credentials. Check them every time.

### Phase 3 — Gaining Access (Exploitation)

**Goal:** turn a candidate vulnerability into a working foothold.

| Attack class | Example techniques |
|---|---|
| Authentication | Credential stuffing, password spraying, Hydra brute-force |
| Web injection | SQL injection, command injection, SSTI, XSS |
| Deserialization | YAML/Pickle/Java deserialization |
| File upload abuse | Polyglot files, MIME bypass, extension bypass |
| Service misconfiguration | Anonymous FTP, open Redis, exposed Jenkins, Webmin |
| Published exploits | Searchsploit, Exploit-DB, Metasploit modules |

**Class examples exercised:**
- Pickle Rick — credentials in HTML comments + `robots.txt` → authenticated web shell
- Boiler CTF — Sar2HTML `plot=` command injection → log file credentials → SSH
- Mr Robot — WordPress enumeration → credential brute-force → PHP reverse shell

### Phase 4 — Maintaining Access (Persistence)

**Goal:** ensure continued access despite reboots, patches, and user activity — **within scope only**.

| Technique | Notes |
|---|---|
| SSH key drop | Appending attacker key to `~/.ssh/authorized_keys` |
| Cron jobs | Adding a reverse-shell cron entry |
| Service implants | Modifying systemd units, init scripts |
| User account creation | Adding a backdoor account with sudo |
| Rootkit installation | Kernel / user-mode rootkits (academic coverage only) |

> In this course, persistence was studied conceptually. Destructive or hard-to-remove implants were **not** placed in lab VMs, consistent with the principle that you restore a target to its original state after testing.

### Phase 5 — Covering Tracks

**Goal:** remove obvious evidence of compromise — *carefully*.

The Week 1 instructor emphasis: **deleting logs is itself a red flag**. A clever defender notices absence. Techniques include:

- Clearing shell history: `history -c`, `unset HISTFILE`, `export HISTSIZE=0`
- Log scrubbing: targeted `sed` on `/var/log/auth.log` rather than wholesale deletion
- Timestomping: `touch -r reference_file target_file` to match modification times
- Understanding which files are **monitored** (tripwire, auditd, SIEM forwarding) before touching them

> This was taught as a conceptual defensive lesson: **know what a real attacker would do so you can detect it**. Track-covering was not part of lab submissions.

### Phase 6 — Reporting

**Goal:** deliver a document that the client can act on.

A good pentest report includes:

- **Executive summary** — business-level findings and risk rating
- **Scope statement** — what was tested, what was not, time window
- **Methodology** — frameworks followed
- **Findings** — one per finding: description, evidence, risk rating, affected systems, remediation
- **Timeline** — testing activities by day/hour
- **Appendices** — raw tool output, screenshots, CVE references

Every submission in this course followed a **step-by-step walkthrough** format:
1. Tool used
2. Reason for using the tool
3. Expected outcome
4. Real outcome
5. Screenshot evidence

That structure is essentially a per-step reporting template and carries directly into professional reporting.

---

## Related Frameworks (Reference Only)

| Framework | Focus | Best for |
|---|---|---|
| **Cyber Kill Chain** (Lockheed Martin) | Attacker lifecycle in 7 steps | Threat modeling, defense planning |
| **MITRE ATT&CK** | Tactics, techniques, procedures (TTPs) | Detection engineering, red team scoring |
| **PTES** | Pentest engagement structure | Scoping, reporting, deliverables |
| **OSSTMM** | Scientific testing measurements | Metrics-driven security testing |
| **OWASP Testing Guide** | Web-application specific | Web pentests |
| **NIST SP 800-115** | US federal pentest guidance | Compliance-driven engagements |

---

## Authorized / Unauthorized / Semi-Authorized

The course updated older "white-hat / black-hat / gray-hat" language to:

- **Authorized user** — working under explicit written contract and scope
- **Unauthorized user** — malicious actor operating without consent
- **Semi-authorized user** — acting with good intent but without explicit authorization (formerly "gray hat")

The line that distinguishes authorized work from a criminal offence is a **signed agreement defining scope, targets, and time window**. That document is the difference between a penetration tester and a defendant.

---

_Previous page:_ [README](../README.md) · _Next page:_ [Cyber Kill Chain](cyber-kill-chain.md)
