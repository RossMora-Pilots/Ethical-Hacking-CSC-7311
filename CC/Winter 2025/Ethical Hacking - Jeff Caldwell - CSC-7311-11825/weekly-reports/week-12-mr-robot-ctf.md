# Week 12 — Mr. Robot CTF (WordPress Exploitation)

> **Date:** ~2025-03-31 · **Deliverable:** Large lab — TryHackMe Mr. Robot CTF

## Session Summary

Full hands-on CTF exercise against a WordPress-based target themed on the USA Network TV show *Mr. Robot*. The room tests the full lifecycle: reconnaissance → CMS enumeration → brute-force → authenticated RCE → reverse shell → privilege escalation — all inside a single contained VM.

## Attack Path (Summary)

```text
Nmap 80/tcp
   ↓
robots.txt → key-1-of-3.txt + fsocity.dic
   ↓
WordPress discovered → enumerate user "elliot"
   ↓
WPScan + deduplicated fsocity.dic → password "ER28-0652"
   ↓
WP admin → theme editor → PHP reverse shell
   ↓
Shell as daemon → find password.raw-md5
   ↓
John the Ripper crack → "abcdefghijklmnopqrstuvwxyz"
   ↓
su robot → key-2-of-3.txt
   ↓
SUID nmap → nmap --interactive → !sh → root
   ↓
key-3-of-3.txt
```

## Key Techniques Exercised

- **robots.txt misconfiguration** as an info disclosure vector
- **WordPress username enumeration** via error message leakage
- **Dictionary deduplication** before brute-force (858k → 11.5k lines)
- **WPScan** for WordPress-specific brute-force
- **PHP reverse shell via theme editor** — the textbook WP admin → RCE path
- **Shell upgrade** via `python -c 'import pty; pty.spawn("/bin/bash")'`
- **MD5 cracking** with John the Ripper
- **SUID nmap privilege escalation** (older Nmap `--interactive` mode)

## Full Walkthrough

See the complete step-by-step walkthrough with tool reasoning, expected vs. actual outcomes, and commentary on defensive implications:

**→ [ctf-walkthroughs/mr-robot-ctf.md](../ctf-walkthroughs/mr-robot-ctf.md)**

## Lab Deliverable

Source file: `Week 12/A00322717 Ross Moravec Lab Mr Robot CTF Wordpress.docx` (5.6 MB — largest regular-week submission in the course, reflecting the depth of WordPress enumeration required).

## Mapping to Course Progression

This lab consolidated the techniques from Weeks 4 (Nmap/web security), 5 (enumeration/brute force), and 6 (network services), and set up the final-exam CTF on the same skills at higher difficulty.

## References from this Session

- Full walkthrough: [mr-robot-ctf.md](../ctf-walkthroughs/mr-robot-ctf.md)
- [Tools](../references/tools.md) — WPScan, John the Ripper, GTFOBins
- [OWASP Top 10](../references/owasp-top-10.md) — A07 (Auth Failures) and A05 (Misconfiguration)

---

*Previous:* [Week 11](week-11-live-host-scanning-wireless.md) · *Next:* [Week 13 — Final Exam](week-13-final-exam-boiler-ctf.md)
