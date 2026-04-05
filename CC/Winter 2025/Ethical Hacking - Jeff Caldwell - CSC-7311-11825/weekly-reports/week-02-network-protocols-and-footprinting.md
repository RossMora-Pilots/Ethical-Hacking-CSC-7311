# Week 2 — Network Protocol Refresher, Footprinting, Social Engineering

> **Date:** 2025-01-20 · **Format:** In-person + Zoom · **Duration:** 3 hours

## Session Summary

Re-established the networking fundamentals that every subsequent week relied on, then expanded into the reconnaissance phase with footprinting and social engineering concepts.

## Topics Covered

### 1. Protocol Refresher

A deliberate "re-hash" (instructor's term) of:

- **TCP/IP stack** layers and responsibilities
- **OSI model** (7 layers) mapped to TCP/IP (4 layers)
- **Common port/service bindings** — 21 FTP, 22 SSH, 23 Telnet, 25 SMTP, 53 DNS, 80 HTTP, 110 POP3, 143 IMAP, 443 HTTPS, 445 SMB, 3306 MySQL, 3389 RDP, 5900 VNC, 8080/8443 HTTP-ALT
- **Protocol characteristics** — TCP vs UDP; stateful vs stateless; encrypted vs plaintext

This material was declared prerequisite knowledge; the session was a refresher, not an introduction.

### 2. Footprinting (Reconnaissance)

Footprinting establishes what an attacker can learn about a target **without touching it**.

| Technique | Output |
|---|---|
| WHOIS | Registrar, admin/tech contacts, nameservers, registration dates |
| DNS enumeration | A/AAAA/MX/TXT/CNAME records; zone-transfer attempts |
| Reverse DNS | Mapping IP ranges to hostnames |
| Certificate transparency logs | Subdomain discovery via `crt.sh` |
| Search engine operators | `site:`, `intitle:`, `inurl:`, `filetype:` (Google dorks) |
| Shodan / Censys | Internet-wide service inventory |
| Metadata analysis | Document author fields, internal paths in PDFs/Office docs |
| LinkedIn / social media | Employee lists, technology stack hints, travel patterns |

> [!NOTE]
> Passive reconnaissance is legally distinct from active scanning — you are querying public data sources, not the target's infrastructure. That said, logging and rate-limiting on services like Shodan mean your queries may still leave traces.

### 3. Social Engineering

Non-technical attacks that exploit **people** rather than **systems**.

| Vector | Example |
|---|---|
| **Phishing** | Email impersonating IT support requesting credentials |
| **Spear phishing** | Targeted, personalized phishing to specific individuals |
| **Whaling** | Phishing aimed at executives |
| **USB drops** | Malicious USB sticks scattered in employee parking lots |
| **QR-code abuse** | Malicious QR codes posted in physical locations |
| **Pretexting** | Impersonating a vendor, colleague, or authority |
| **Tailgating** | Physical entry by following an authorized person |
| **Vishing** | Voice-phishing via phone calls |
| **Smishing** | SMS-based phishing |

**Ethical framing:** social engineering is only acceptable within an engagement that has **explicit authorization** for it — most contracts carve it out because of HR and legal sensitivities.

> [!TIP]
> Phishing remains the number-one initial access vector in real-world breaches. Building a phishing simulation for a client requires its own scope document, separate from the network pentest authorization.

## Reading & Preparation

- Read assigned TryHackMe rooms on reconnaissance and footprinting
- Prepare for Week 3 Cyber Kill Chain assignment

## Lecture Recording

Session recording (`.mp4`) and auto-generated transcript (`.txt`) available in the source course folder on institutional storage.

## Key Takeaway

Passive reconnaissance reveals far more than most people realize. Certificate transparency logs and Google dorks can expose internal infrastructure — subdomains, staging servers, forgotten admin panels — without ever sending a single packet to the target. The attacker's first move is almost always free and invisible.

## References from this Session

- [Cyber Kill Chain](../references/cyber-kill-chain.md) — phase 1 (reconnaissance) maps to this week
- [Methodology](../references/methodology.md) — phases 1 & 2

---

_Previous:_ [Week 1](week-01-course-introduction.md) · _Next:_ [Week 3](week-03-cyber-kill-chain.md)
