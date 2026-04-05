# CTF Walkthroughs

Complete step-by-step walkthroughs for the three graded TryHackMe rooms completed in CSC-7311.

| # | Room | Purpose | Difficulty | Link |
|---|---|---|---|---|
| 1 | Pickle Rick | Midterm exam | Easy | [midterm-pickle-rick.md](midterm-pickle-rick.md) |
| 2 | Mr. Robot CTF | Week 12 Large Lab | Medium | [mr-robot-ctf.md](mr-robot-ctf.md) |
| 3 | Boiler CTF | Final exam | Medium | [final-boiler-ctf.md](final-boiler-ctf.md) |

## Cross-CTF Comparison

| Dimension | Pickle Rick | Mr. Robot | Boiler CTF |
|---|---|---|---|
| **Initial access vector** | Web command injection via portal | WordPress admin → PHP theme editor | Sar2HTML RCE via `plot=` parameter |
| **Privilege escalation** | `sudo -l` → NOPASSWD:ALL | SUID nmap `--interactive` → root shell | SUID `/usr/bin/find -exec /bin/sh -p` |
| **Credential discovery** | HTML comments + `robots.txt` | `robots.txt` wordlist + WPScan brute-force + MD5 hash | FTP `.info.txt` + log file + backup.sh |
| **Key technique** | `cat` filter bypass via `less` | Wordlist deduplication (858k → 11.5k) | Multi-level directory brute-forcing |
| **Services exploited** | HTTP (80), SSH (22) | HTTP (80), HTTPS (443) | FTP (21), HTTP (80), SSH (55007) |
| **OWASP categories hit** | A01, A03, A05 | A01, A02, A05, A07 | A01, A03, A05, A06 |
| **Complexity** | Single-stage (web → root) | Multi-stage (web → user → root) | Multi-stage (FTP → web → SSH → user → root) |
| **Screenshots** | 25 | 1 | 21 |

### Patterns Across All Three Rooms

1. **Credential exposure is universal.** Every room leaked credentials through files left in web roots, comments, `robots.txt`, or insecure scripts. In production, this maps to the most common real-world finding.
2. **Enumeration discipline decides outcomes.** The Boiler CTF's Sar2HTML was hidden behind two levels of Gobuster — testers who stop after the first pass miss it. Thoroughness beats speed.
3. **SUID binaries are a reliable escalation path.** Two of three rooms used SUID abuse (nmap, find). The `find / -perm -4000` command should be muscle memory for any pentester.
4. **Methodology works.** All three rooms yielded to the same six-phase lifecycle (recon → enum → exploit → post-exploit → privesc → report). No tricks or esoteric techniques required — just systematic execution.

Each walkthrough follows the course-mandated format:

1. **Tool used** — which instrument was employed
2. **Reason for tool** — one-or-two-sentence justification
3. **Expected outcome** — tester's hypothesis
4. **Real outcome** — what actually happened
5. **Evidence** — screenshot reference

Each walkthrough additionally includes:

- **Methodology notes** — where this maps in the pentest lifecycle
- **OWASP Top 10 mapping** — which categories the findings illustrate
- **MITRE ATT&CK mapping** — specific techniques exercised
- **Key learnings** — pedagogical takeaways
- **Remediation recommendations** — what a client should fix

---

Back to [course README](../README.md).
