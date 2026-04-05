# Course Outline — CSC-7311 Ethical Hacking

Reconstructed from the Week 1 orientation transcript (2025-01-13) and from the syllabus slide content. This is a pedagogical summary; the official course outline lives in Moodle.

## Course Description

Ethical Hacking (CSC-7311) teaches the role and practice of a **penetration tester** working under legal authorization. Students learn the methodology used to identify vulnerabilities in networks, systems, and web applications; the tooling that enables this; and the ethical, legal, and regulatory framework that distinguishes authorized security testing from criminal activity.

The course emphasizes **hands-on lab work**. The majority of each class session after orientation was dedicated to completing TryHackMe rooms and capturing evidence for submission.

## Learning Outcomes

Upon completion, students can:

1. **Discuss the ethical and legal boundaries** of hacking and the role of the penetration tester under Canadian law and contractual scope.
2. **Describe common network protocol layers** (TCP/IP, OSI) and the services that authorized testers interact with.
3. **Apply network footprinting and social engineering** methods to obtain reconnaissance intelligence about a target.
4. **Evaluate desktop and server operating systems and web platforms** to understand common vulnerabilities and prevention strategies.
5. **Assess wireless network vulnerabilities** — including public networks, Wi-Fi Pineapple-style rogue APs, RFID/NFC access card cloning, and sub-gigahertz radio attacks.
6. **Apply network protection systems** on local and cloud infrastructure to defend against the attacks studied.

## Topics Covered

| Block | Topics |
|---|---|
| **Legal & Ethical** | Canadian Criminal Code sections on computer crime; privacy laws (PIPEDA); cyber-law trends; data breach case studies (PowerSchool, Indigo, etc.); authorized / semi-authorized / unauthorized hacker classifications; bug bounty programs; responsible disclosure; NDA scoping |
| **Methodology** | Cyber Kill Chain (Lockheed Martin); MITRE ATT&CK framework; Penetration Testing Execution Standard (PTES); Open Source Security Testing Methodology Manual (OSSTMM) |
| **Networking Refresher** | TCP/IP stack; OSI model; common ports & services; protocol characteristics |
| **Reconnaissance** | Open-source intelligence (OSINT); footprinting; WHOIS; DNS; service fingerprinting |
| **Social Engineering** | Phishing site construction; malicious USB drops; QR-code abuse; pretexting |
| **Scanning & Enumeration** | Nmap; service/version detection; banner grabbing; SMTP/FTP enumeration; directory brute-forcing |
| **Vulnerability Assessment** | OpenVAS; CVE research; CVSS prioritization; false positive triage |
| **Web Application Security** | OWASP Top 10; command injection; authentication bypass; CMS-specific tooling (JoomScan, WPScan) |
| **Exploitation** | Remote code execution; credential stuffing; SUID abuse; sudo misconfiguration |
| **Wireless & Physical** | Wi-Fi Pineapple; rogue AP; RFID/NFC cloning; Flipper Zero; sub-GHz signals |
| **Defense & Reporting** | Network protection systems; logging; monitoring; incident response; report writing |

## Course Format

- **Schedule:** Mondays, 17:30–20:30, Room 1215 (Cambrian campus) + Zoom broadcast
- **Structure per session:** brief lecture / demo → hands-on lab → instructor Q&A
- **Assessments:**
  - 6 small labs / activities
  - 4 large multi-part labs
  - 4 quizzes (multiple choice + short answer, open-book, full-day window)
  - 1 practical **midterm** (during class time, locked down / monitored)
  - 1 practical **final** (during class time, locked down / monitored)
- **Open-book policy:** all work may reference internet materials; screenshots required to prove hands-on effort
- **Late policy:** work due 23:59 the day of the class; typically one week between classes to complete the assigned lab

## Prerequisites Assumed

The course is **not an intro to Linux, Windows Server, or networking**. Students are expected to already know how to:

- Install software on Linux and Windows; update operating systems; troubleshoot; configure IP addressing
- Install and configure a Windows Server role; manage services; administer accounts
- Articulate the TCP/IP stack; identify standard ports for web/FTP/SSH/DNS/SMTP; understand basic Cisco/physical networking concepts

Students missing any of these are expected to self-study to keep pace.

## Tooling & Platform

| Category | Choice |
|---|---|
| **Attack platform** | Kali Linux (pre-built image recommended) |
| **Virtualization** | VirtualBox (VMware ESXi also supported) |
| **Lab platform** | TryHackMe (free tier sufficient; paid Attack Box optional) |
| **LMS** | Moodle (slide decks, blog articles, YouTube links, walkthroughs) |
| **Submission** | Moodle (PDF format) |

## Instructor

**Jeff Caldwell** — Professor at Cambrian College. Background in software development and IT analysis; experience as project planner, software developer, and cybersecurity educator. Self-describes as a "night owl" — responds to email within 48 hours, often after midnight. Available for 1:1 meetings and group sessions outside class time by appointment.

---

_This outline is a reconstructed summary. The canonical syllabus lives in Moodle and may include additional administrative details (accommodation policies, academic integrity statements, grading rubrics) not reproduced here._
