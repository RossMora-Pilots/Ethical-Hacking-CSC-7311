# Week 1 — Course Introduction, Ethics, Methodology, Lab Setup

> **Date:** 2025-01-13 · **Format:** In-person + Zoom broadcast · **Duration:** 3 hours

## Session Summary

The opening session covered administrative orientation, established the ethical and legal baseline for the course, reviewed the penetration-testing lifecycle, and walked students through building the hands-on lab environment.

## Topics Covered

### 1. Course Administration

- Instructor introduction (Jeff Caldwell, 3+ years at Cambrian)
- Schedule: Mondays 17:30–20:30, Room 1215 + Zoom
- Grading structure: 6 labs + 4 activities + 4 quizzes + midterm + final
- Communication: email with ~48-hour response
- No textbook — TryHackMe + Moodle for all resources
- Open-book policy with screenshot evidence required

### 2. Ethical and Legal Framework

> [!CAUTION]
> The instructor made clear from the first session: unauthorized computer access is a criminal offence under Canadian law. The entire course operates within the boundary of intentionally vulnerable lab targets.

- **Canadian Criminal Code** provisions: s. 342.1 (unauthorized use of a computer), s. 430(1.1) (mischief to data), s. 184 (interception)
- **Privacy laws:** PIPEDA + provincial variants
- **Hacker classification:** white/grey/black hat → authorized/semi-authorized/unauthorized
- **Responsible disclosure:** vendor notification, disclosure timelines, bug bounty programs
- **Data breach case studies:** PowerSchool (late 2024), Indigo/Chapters (Feb 2023)
- **Ethical behaviour checklist:** responsible disclosure, confidentiality, no tool misuse, transparency, scope discipline

Detailed treatment: [references/legal-and-ethics.md](../references/legal-and-ethics.md)

### 3. Penetration-Testing Methodology

- Why methodology matters (consistency, repeatability, verifiability, gap coverage)
- Six-phase lifecycle: Recon → Enum → Access → Persistence → Cover Tracks → Report
- Framework landscape: **Cyber Kill Chain** (primary), **MITRE ATT&CK**, **PTES**, **OSSTMM**
- "Covering tracks" discussion: deleting logs is itself a red flag

Detailed treatment: [references/methodology.md](../references/methodology.md)

### 4. Lab Environment Setup

> [!TIP]
> Take a VM snapshot immediately after a clean Kali install and again after initial configuration. Having a known-good baseline to revert to saves hours when a room or exploit breaks the environment.

Students installed:

- **VirtualBox** (hypervisor)
- **Kali Linux** (pre-built penetration testing VM)
- **TryHackMe account** (free tier)

Alternate paths supported:

- VMware ESXi instead of VirtualBox
- Paid TryHackMe Attack Box for browser-only access

## Prerequisites Reiterated

Instructor explicitly reminded students that CSC-7311 is **not** an intro to Linux, Windows Server, or networking. Students missing working knowledge in any of these were warned they would face additional self-directed learning to keep pace.

## Demonstrations Previewed

- **Wi-Fi Pineapple** (rogue AP hardware)
- **Flipper Zero** (sub-GHz RF, RFID/NFC cloning)

## Student Activity

- Read Moodle course outline
- Install VirtualBox + Kali image
- Create TryHackMe account
- Verify VPN connectivity (OpenVPN profile)
- Complete intro TryHackMe rooms

## Key Quotes

> "You get to learn how to hack into computers — just do it legally, basically."
>
> "You are going to jail for that kind of thing. Especially these days."
>
> "Something can be observed as an illegal activity if you're outside of the bounds of where you're supposed to be."

## Key Takeaway

The legal framework isn't just a lecture topic — it's the foundation that makes everything else in this course possible. Understanding s.342.1 of the Criminal Code before touching any tool is what separates a career from a prosecution. That message landed on day one and set the tone for every session that followed.

## References from this Session

- [Course outline](../course-outline.md)
- [Legal & Ethics](../references/legal-and-ethics.md)
- [Methodology](../references/methodology.md)
- [Cyber Kill Chain](../references/cyber-kill-chain.md)

---

_Previous:_ (course start) · _Next:_ [Week 2](week-02-network-protocols-and-footprinting.md)
