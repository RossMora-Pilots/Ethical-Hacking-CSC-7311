# Week 10 — Phishing Analysis & Phishing in Action

> **Date:** ~2025-03-17 · **Deliverable:** Two-part lab (Phishing Analysis + Phishing in Action)

## Session Summary

Moved from technical exploitation to **human-layer attacks**. Phishing is the most commonly reported initial-access vector in published incident data and the single highest-ROI attack path for adversaries who want to avoid burning technical exploits.

## Part 1 — Phishing Analysis (Defender Lens)

**Goal:** take a received phishing email and decompose it to identify **indicators of phishing**.

### Indicators Examined

| Indicator | What to look for |
|---|---|
| **Sender address** | Spoofed display name vs. actual email address; lookalike domains (`paypaI.com` with capital-I) |
| **Return-Path / Reply-To** | Mismatch with visible sender |
| **SPF / DKIM / DMARC** | `spf=fail`, `dkim=none`, `dmarc=fail` in email headers |
| **Received: headers** | Unexpected intermediate hops, source IPs not belonging to claimed sender |
| **URL inspection** | Hover (don't click!); examine URL for lookalikes, URL shorteners, encoded characters |
| **Urgency / fear tactics** | "Your account will be suspended in 24 hours" |
| **Generic greetings** | "Dear Customer" instead of actual name |
| **Grammar / spelling** | Awkward phrasing typical of automated translation or non-native speakers |
| **Attachment type** | `.zip`, `.iso`, `.lnk`, `.docm`, `.html` are common payload containers |
| **Brand mismatch** | Logo slightly wrong, colors off, footer outdated |

### Header Analysis Walkthrough

Email headers were read top-to-bottom to trace the message's path:

1. **Examine `Received:` chain** — newest header at top, oldest at bottom. Verify each hop.
2. **Check `Return-Path`** — where bounces actually go (often the attacker's drop address).
3. **Check `Authentication-Results`** — SPF / DKIM / DMARC verdicts.
4. **Compare `From:` vs. `Return-Path:`** — mismatches are suspicious.
5. **Inspect `X-` headers** — provider-specific metadata sometimes exposes origin.

### Link & Attachment Handling (Safely)

- **Sandboxed opening** — never open on a production workstation; use an isolated VM or cloud sandbox (any.run, Joe Sandbox, VirusTotal).
- **URL decoding** — run suspicious URLs through `urldecode`, CyberChef, or URLScan.io.
- **Static analysis of docs** — `olevba`, `oledump.py` for Office macros; `exiftool` for metadata.
- **Never enable macros** — if a document prompts to enable content, it is almost certainly malicious.

## Part 2 — Phishing in Action (Attacker Lens — Ethical)

**Goal:** understand how phishing payloads are **constructed** so defenders can predict them. Scoped to lab targets / volunteer accounts only.

### Payload Construction

- **Credential harvesting page** — clone of a login page posting credentials to attacker-controlled endpoint
- **Payload delivery** — HTML email, PDF with embedded link, Office document with macro
- **Landing page hosting** — attacker-owned domain with HTTPS cert (Let's Encrypt) for credibility
- **Pretext development** — business context that makes the ask plausible

### Tooling Landscape (Referenced, Not Executed Against Real Targets)

| Tool | Purpose |
|---|---|
| **GoPhish** | Open-source phishing framework with campaign management |
| **Evilginx** | Reverse-proxy phishing for 2FA/MFA bypass |
| **SEToolkit** | Social-Engineer Toolkit — email/SMS phishing, credential harvesting |
| **Modlishka** | Reverse-proxy phishing |
| **King Phisher** | Full-featured phishing campaign platform |

### Defensive Recommendations from this Week

1. **MFA everywhere** — especially resistant MFA (FIDO2, WebAuthn) — neutralizes credential phishing
2. **DMARC enforcement** (`p=reject`) — prevents domain spoofing
3. **URL rewriting & sandboxing** in mail flow
4. **Security awareness training** — frequent, outcome-measured
5. **Simulated phishing programs** — tracked metrics, targeted follow-up with repeat clickers
6. **Report button** — a one-click mechanism for users to report suspicious email to security team
7. **Email tagging** — `[EXTERNAL]` prefix on emails from outside the org

## Ethical Boundary (Reiterated)

Phishing simulations are acceptable **only** under written authorization, typically within an organization's own security-awareness program. Phishing an external party — even for "educational" purposes — crosses into criminal fraud territory. The course reinforced that every technique in Part 2 exists to make defenders stronger, not to enable unauthorized attacks.

## Lab Deliverable

Two-part combined submission:

- **Part 1:** received phishing email analysis with annotated screenshots identifying indicators
- **Part 2:** controlled construction demonstration in the course lab environment

Source file: `Week 10/A00322717 Ross Moravec Phishing Analysis [PART 1] and Phishing in Action [PART 2].docx` (3.9 MB, 2 embedded sections). Transcript: `Week 10/Transcript.txt` (18 KB).

## TryHackMe Rooms Referenced

- [Phishing Emails in Action](https://tryhackme.com/room/phishingemails2tryoe)
- [Phishing Analysis Tools](https://tryhackme.com/room/phishingemails4mimic)
- [Phishing Prevention](https://tryhackme.com/room/phishingemails5fwfrv)

## References from this Session

- [Methodology](../references/methodology.md) — Phase 3 (delivery via social engineering)
- [Cyber Kill Chain](../references/cyber-kill-chain.md) — Delivery phase
- [Tools](../references/tools.md)

---

_Previous:_ [Week 6](week-06-network-services.md) · _Next:_ [Week 11](week-11-live-host-scanning-wireless.md)
