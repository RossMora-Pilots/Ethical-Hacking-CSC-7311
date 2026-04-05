# Cyber Kill Chain

The **Cyber Kill Chain** was developed by Lockheed Martin as a threat-intelligence framework describing the phases of a targeted cyber attack. Understanding it helps both offense (structuring an engagement) and defense (interrupting the chain at any stage stops the attack).

> Course deliverable for Week 3 was the two-part Cyber Kill Chain assignment; this document is the study companion summarizing the model.

## The Seven Phases

```
 1. Reconnaissance   →  2. Weaponization   →  3. Delivery   →  4. Exploitation
                                                                    ↓
 7. Actions on       ←  6. Command &       ←  5. Installation
    Objectives          Control (C2)
```

### 1. Reconnaissance
**Attacker activity:** research the target — employees, technology stack, public-facing systems, business context.
**Defender response:** monitor access to sensitive public data; scrub metadata; limit social-media over-disclosure; alert on reconnaissance scanning.

### 2. Weaponization
**Attacker activity:** pair an exploit with a deliverable payload — e.g., malicious macro in a Word document, LNK file with encoded PowerShell, custom C2 beacon.
**Defender response:** cannot be observed directly (happens on attacker infrastructure); defended against via payload detonation analysis (sandbox), signature generation, YARA rules.

### 3. Delivery
**Attacker activity:** transmit the weaponized payload — phishing email, watering-hole website, USB drop, supply-chain injection.
**Defender response:** email filtering, URL rewriting, attachment sandboxing, user awareness training.

### 4. Exploitation
**Attacker activity:** the payload triggers — e.g., exploit a CVE in a PDF reader; user enables macros; user clicks a malicious link.
**Defender response:** patching, EDR behavioural detection, application allowlisting, macro blocking.

### 5. Installation
**Attacker activity:** install persistence — service, scheduled task, registry run key, crontab, systemd unit.
**Defender response:** EDR (monitors process creation, autoruns), HIDS, integrity monitoring, endpoint baselines.

### 6. Command & Control (C2)
**Attacker activity:** establish a channel back to attacker infrastructure — HTTPS beacon, DNS tunneling, Telegram bot, legitimate-looking cloud service.
**Defender response:** egress filtering, DNS sinkholes, anomaly detection, TLS inspection, threat intel feeds.

### 7. Actions on Objectives
**Attacker activity:** achieve the mission — data exfiltration, ransomware deployment, lateral movement, privilege escalation, destruction.
**Defender response:** DLP, segmentation, backup integrity, honey tokens, incident response.

## Why it matters for defense

**Break the chain at any step to break the attack.** A single control failure is rarely fatal; layered controls mean an attacker must succeed at every stage while the defender only needs to catch them once.

This is the origin of the phrase **"defense in depth"** — the kill chain formalizes why stacking imperfect controls still works.

## Kill Chain vs. MITRE ATT&CK

| | Kill Chain | ATT&CK |
|---|---|---|
| **Scope** | Linear attack lifecycle | Matrix of tactics × techniques × procedures |
| **Phases** | 7 | 14 tactics with 200+ techniques |
| **Use case** | Strategic threat modeling | Detection engineering, red-team scoring |
| **Granularity** | Coarse (phase-level) | Fine (technique-level with procedures) |
| **Update cadence** | Rarely revised | Quarterly updates |

Both models are useful. The Kill Chain is better for **"how do we stop this class of attack?"** while ATT&CK is better for **"do our detections cover technique T1059?"**.

## Real-World Case Studies Discussed in Class

| Incident | Example phase breakdown |
|---|---|
| **PowerSchool breach** (late 2024) | Recon → credential compromise → data exfiltration across 6 Canadian provinces + multiple US states |
| **Indigo/Chapters/Coles** (Feb 2023) | Ransomware — complete e-commerce shutdown for a month, loss of debit/credit processing for a week |
| **Hybrid warfare case studies** | State-sponsored APT activity against telecom, utilities, government infrastructure |

## Using the Kill Chain in an Engagement

As a **penetration tester**, the kill chain provides a reporting template:

1. **Did we succeed at reconnaissance?** What did we find that was unintended exposure?
2. **Could we weaponize / deliver a payload?** What channels worked?
3. **Did exploitation succeed?** Which vulnerabilities?
4. **Did installation / C2 succeed?** How long did it take defenders to notice?
5. **What objectives were achievable?** Data access, destruction, pivoting?

A client reading this structure can translate findings directly into defensive investment priorities: "we failed at step 3, add mail-filter tuning" or "we failed at step 6, add egress filtering."

---

_Previous page:_ [Methodology](methodology.md) · _Next page:_ [Legal & Ethics](legal-and-ethics.md)
