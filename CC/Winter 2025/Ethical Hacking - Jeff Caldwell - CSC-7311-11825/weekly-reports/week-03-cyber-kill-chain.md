# Week 3 — Cyber Kill Chain (Parts 1 & 2)

> **Deliverable:** Written assignment — "Cyber Kill Chain (Part 1 and Part 2)" submitted via Moodle in PDF format

## Session Summary

Applied the Lockheed Martin **Cyber Kill Chain** as the first formal framework studied in the course, with attention to how each phase corresponds to defensive controls. The deliverable combined a conceptual walk-through (Part 1) with a practical mapping exercise (Part 2).

## Topics Covered

### Part 1 — The Seven Phases (Conceptual)

1. **Reconnaissance** — target research
2. **Weaponization** — exploit + payload coupling
3. **Delivery** — payload transmission
4. **Exploitation** — vulnerability trigger
5. **Installation** — persistence establishment
6. **Command & Control (C2)** — attacker communication channel
7. **Actions on Objectives** — mission completion

Detailed treatment: [references/cyber-kill-chain.md](../references/cyber-kill-chain.md)

### Part 2 — Application

The assignment asked students to:

- Select a real-world incident or APT campaign
- Map observed attacker behaviours to each of the seven phases
- Identify which defensive controls would have broken the chain at each phase
- Discuss which phase offers the best ROI for defensive investment

**Key insight articulated in the assignment:** defense-in-depth is a direct consequence of the kill chain model. An attacker must succeed at every phase; a defender only needs to detect or prevent at **one**.

> [!TIP]
> Defense-in-depth is the direct corollary of the kill chain: because the attacker must succeed at every phase, layering controls across multiple phases dramatically raises the cost of a successful attack. When budgeting for defenses, map each control to the kill chain phase it disrupts.

## Defensive Mapping Table

| Kill Chain Phase | Defensive Controls |
|---|---|
| Reconnaissance | Metadata scrubbing, WHOIS privacy, OPSEC training, anomaly detection on scanning |
| Weaponization | Not directly observable — counter via sandbox detonation, YARA rules |
| Delivery | Email filtering, URL rewriting, attachment sandboxing, awareness training |
| Exploitation | Patching, EDR behavioural detection, app allowlisting, macro blocking |
| Installation | EDR autorun monitoring, HIDS, integrity monitoring, baseline enforcement |
| Command & Control | Egress filtering, DNS sinkholes, anomaly detection, TLS inspection |
| Actions on Objectives | DLP, segmentation, backup integrity, honey tokens, IR playbooks |

## Kill Chain vs. MITRE ATT&CK

The course explicitly contrasted the two frameworks:

- **Kill Chain** — strategic, 7 phases, ideal for threat modeling and defense prioritization
- **ATT&CK** — tactical, 14 tactics × 200+ techniques, ideal for detection engineering and red-team scoring

Both were established as complementary; the course subsequently used ATT&CK technique IDs when mapping specific CTF actions.

## Student Work

Assignment submitted as a Word document with conceptual write-up and mapping tables. Submission file in source: `Week 3/A00322717 Ross Moravec Cyber Kill Chain (Part 1 and Part 2).docx` (2.3 MB, 4 embedded images).

![Cyber Kill Chain — phase overview and mapping diagram](../screenshots/wk03_cyber_kill_chain_01.png)

![Kill chain applied to a real-world APT campaign](../screenshots/wk03_cyber_kill_chain_02.png)

![Defensive controls mapped to each kill chain phase](../screenshots/wk03_cyber_kill_chain_03.png)

![Kill chain vs. MITRE ATT&CK comparison](../screenshots/wk03_cyber_kill_chain_04.png)

> [!NOTE]
> The original assignment document embeds these images inline with the written analysis. They are reproduced here for portfolio accessibility.

## Key Takeaway

The kill chain's most powerful insight is for defenders, not attackers: you only need to break one link. That realization shifted my perspective from "how do I get in?" to "where should the organization invest?" Thinking about cost-per-phase-disrupted is what turns a vulnerability list into an actionable security strategy.

## References from this Session

- [Cyber Kill Chain](../references/cyber-kill-chain.md)
- [Methodology](../references/methodology.md)
- Lockheed Martin — [original kill chain paper](https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html)
- [MITRE ATT&CK](https://attack.mitre.org/)

---

_Previous:_ [Week 2](week-02-network-protocols-and-footprinting.md) · _Next:_ [Week 4](week-04-nmap-osi-web-app-security.md)
