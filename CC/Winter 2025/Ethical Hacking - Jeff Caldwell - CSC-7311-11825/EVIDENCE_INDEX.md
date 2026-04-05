# Evidence Index

> Auto-generated screenshot inventory extracted from source DOCX submissions.
> **67 unique screenshots** across 13 topics from 13 weeks of coursework.

---

## Summary

| Week | Topic | Screenshots | Key Tools Visible |
|------|-------|:-----------:|-------------------|
| 3 | Cyber Kill Chain | 4 | TryHackMe, browser |
| 4 | Further Nmap | 2 | Nmap, terminal |
| 4 | OSI & Recon — Web App Security | 2 | Nmap, browser |
| 5 | Enumeration, Brute Force, OpenVAS | 2 | OpenVAS, Hydra, terminal |
| 6 | Network Services | 3 | Nmap, SMB, FTP, terminal |
| 8 | **Midterm — Pickle Rick** | 25 | Nmap, Gobuster, Nikto, curl, browser, sudo |
| 10 | Phishing Analysis | 2 | Email headers, browser |
| 11 | Nmap Live Host Discovery | 1 | Nmap |
| 11 | Wireless Hacking 101 | 1 | TryHackMe |
| 12 | **Mr. Robot CTF** | 1 | WordPress, WPScan |
| 13 | **Boiler CTF (Final Exam)** | 21 | Nmap, Gobuster, JoomScan, Sar2HTML, SSH, GTFOBins |
| 13 | ETH Final Exam | 2 | Multiple |
| 13 | OWASP Top 10 | 1 | OWASP reference |
| | **Total** | **67** | |

---

## Week 3 — Cyber Kill Chain

| # | File | Description |
|---|------|-------------|
| 1 | [`wk03_cyber_kill_chain_01.png`](screenshots/wk03_cyber_kill_chain_01.png) | TryHackMe room — Cyber Kill Chain overview |
| 2 | [`wk03_cyber_kill_chain_02.png`](screenshots/wk03_cyber_kill_chain_02.png) | Kill Chain phases — Reconnaissance through Actions |
| 3 | [`wk03_cyber_kill_chain_03.png`](screenshots/wk03_cyber_kill_chain_03.png) | Kill Chain phases — continued |
| 4 | [`wk03_cyber_kill_chain_04.png`](screenshots/wk03_cyber_kill_chain_04.png) | Kill Chain completion / summary |

---

## Week 4 — Further Nmap

| # | File | Description |
|---|------|-------------|
| 1 | [`wk04_further_nmap_01.png`](screenshots/wk04_further_nmap_01.png) | Nmap advanced scan techniques |
| 2 | [`wk04_further_nmap_02.png`](screenshots/wk04_further_nmap_02.png) | Nmap output analysis |

---

## Week 4 — OSI & Recon — Web App Security

| # | File | Description |
|---|------|-------------|
| 1 | [`wk04_osi_recon_webapp_01.png`](screenshots/wk04_osi_recon_webapp_01.png) | OSI model / reconnaissance concepts |
| 2 | [`wk04_osi_recon_webapp_02.png`](screenshots/wk04_osi_recon_webapp_02.png) | Web application security scanning |

---

## Week 5 — Enumeration, Brute Force & OpenVAS

| # | File | Description |
|---|------|-------------|
| 1 | [`wk05_enum_bruteforce_openvas_01.png`](screenshots/wk05_enum_bruteforce_openvas_01.png) | Enumeration / brute-force techniques |
| 2 | [`wk05_enum_bruteforce_openvas_02.png`](screenshots/wk05_enum_bruteforce_openvas_02.png) | OpenVAS vulnerability scanner output |

---

## Week 6 — Network Services

| # | File | Description |
|---|------|-------------|
| 1 | [`wk06_network_services_01.png`](screenshots/wk06_network_services_01.png) | Network services enumeration |
| 2 | [`wk06_network_services_02.png`](screenshots/wk06_network_services_02.png) | SMB / FTP service interaction |
| 3 | [`wk06_network_services_03.png`](screenshots/wk06_network_services_03.png) | Service exploitation results |

---

## Week 8 — Midterm: Pickle Rick CTF

> 25 screenshots documenting the complete Pickle Rick walkthrough.
> See full walkthrough: [midterm-pickle-rick.md](ctf-walkthroughs/midterm-pickle-rick.md)

| # | File | Walkthrough Step | Description |
|---|------|-----------------|-------------|
| 1 | [`wk08_pickle_rick_01.png`](screenshots/wk08_pickle_rick_01.png) | Step 1 | Nmap full-port scan — open ports 22 and 80 |
| 2 | [`wk08_pickle_rick_02.png`](screenshots/wk08_pickle_rick_02.png) | Step 1 | Nmap service version details |
| 3 | [`wk08_pickle_rick_03.png`](screenshots/wk08_pickle_rick_03.png) | Step 2 | Web page — Rick's portal landing page |
| 4 | [`wk08_pickle_rick_04.png`](screenshots/wk08_pickle_rick_04.png) | Step 2 | HTML source — username `R1ckRul3s` in comment |
| 5 | [`wk08_pickle_rick_05.png`](screenshots/wk08_pickle_rick_05.png) | Step 3 | robots.txt — password string `Wubbalubbadubdub` |
| 6 | [`wk08_pickle_rick_06.png`](screenshots/wk08_pickle_rick_06.png) | Step 4 | Gobuster directory enumeration output |
| 7 | [`wk08_pickle_rick_07.png`](screenshots/wk08_pickle_rick_07.png) | Step 4 | Nikto web server scan results |
| 8 | [`wk08_pickle_rick_08.png`](screenshots/wk08_pickle_rick_08.png) | Step 4 | Discovered paths — `/login.php`, `/portal.php` |
| 9 | [`wk08_pickle_rick_09.png`](screenshots/wk08_pickle_rick_09.png) | Step 5 | Login form at `/portal.php` |
| 10 | [`wk08_pickle_rick_10.png`](screenshots/wk08_pickle_rick_10.png) | Step 5 | Successful login — command panel visible |
| 11 | [`wk08_pickle_rick_11.png`](screenshots/wk08_pickle_rick_11.png) | Step 5 | Command panel — test command output |
| 12 | [`wk08_pickle_rick_12.png`](screenshots/wk08_pickle_rick_12.png) | Step 6 | `ls -a` — file listing with ingredient file |
| 13 | [`wk08_pickle_rick_13.png`](screenshots/wk08_pickle_rick_13.png) | Step 6 | `cat` blocked — demonstrating command filter |
| 14 | [`wk08_pickle_rick_14.png`](screenshots/wk08_pickle_rick_14.png) | Step 6 | `less` bypass — first ingredient retrieved |
| 15 | [`wk08_pickle_rick_15.png`](screenshots/wk08_pickle_rick_15.png) | Step 7 | `/home/rick` directory listing |
| 16 | [`wk08_pickle_rick_16.png`](screenshots/wk08_pickle_rick_16.png) | Step 7 | Second ingredient retrieved via `sudo less` |
| 17 | [`wk08_pickle_rick_17.png`](screenshots/wk08_pickle_rick_17.png) | Step 8 | `sudo -l` output — `NOPASSWD: ALL` |
| 18 | [`wk08_pickle_rick_18.png`](screenshots/wk08_pickle_rick_18.png) | Step 8 | `/root` directory listing via sudo |
| 19 | [`wk08_pickle_rick_19.png`](screenshots/wk08_pickle_rick_19.png) | Step 8 | Third ingredient retrieved from `/root/3rd.txt` |
| 20 | [`wk08_pickle_rick_20.png`](screenshots/wk08_pickle_rick_20.png) | Step 8 | Privilege escalation confirmation |
| 21 | [`wk08_pickle_rick_21.png`](screenshots/wk08_pickle_rick_21.png) | Step 9 | TryHackMe ingredient submission |
| 22 | [`wk08_pickle_rick_22.png`](screenshots/wk08_pickle_rick_22.png) | Step 9 | TryHackMe — all three ingredients confirmed |
| 23 | [`wk08_pickle_rick_23.png`](screenshots/wk08_pickle_rick_23.png) | Step 9 | Room progress 100% |
| 24 | [`wk08_pickle_rick_24.png`](screenshots/wk08_pickle_rick_24.png) | Step 9 | Room completion screen |
| 25 | [`wk08_pickle_rick_25.png`](screenshots/wk08_pickle_rick_25.png) | Step 9 | Final room summary |

---

## Week 10 — Phishing Analysis

| # | File | Description |
|---|------|-------------|
| 1 | [`wk10_phishing_01.png`](screenshots/wk10_phishing_01.png) | Phishing email analysis — Part 1 |
| 2 | [`wk10_phishing_02.png`](screenshots/wk10_phishing_02.png) | Phishing in Action — Part 2 |

---

## Week 11 — Nmap Live Host Discovery

| # | File | Description |
|---|------|-------------|
| 1 | [`wk11_nmap_live_host_01.png`](screenshots/wk11_nmap_live_host_01.png) | Live host scanning with Nmap |

---

## Week 11 — Wireless Hacking 101

| # | File | Description |
|---|------|-------------|
| 1 | [`wk11_wireless_hacking_01.png`](screenshots/wk11_wireless_hacking_01.png) | Wireless hacking concepts / TryHackMe |

---

## Week 12 — Mr. Robot CTF

> See full walkthrough: [mr-robot-ctf.md](ctf-walkthroughs/mr-robot-ctf.md)

| # | File | Walkthrough Step | Description |
|---|------|-----------------|-------------|
| 1 | [`wk12_mr_robot_01.png`](screenshots/wk12_mr_robot_01.png) | Overview | WordPress Mr. Robot themed site — initial reconnaissance |

---

## Week 13 — Boiler CTF (Final Exam)

> 21 screenshots documenting the complete Boiler CTF walkthrough.
> See full walkthrough: [final-boiler-ctf.md](ctf-walkthroughs/final-boiler-ctf.md)

| # | File | Walkthrough Step | Description |
|---|------|-----------------|-------------|
| 1 | [`wk13_boiler_ctf_01.png`](screenshots/wk13_boiler_ctf_01.png) | Step 1 | Nmap full-port scan — 4 services discovered |
| 2 | [`wk13_boiler_ctf_02.png`](screenshots/wk13_boiler_ctf_02.png) | Step 1 | Nmap service version fingerprints |
| 3 | [`wk13_boiler_ctf_03.png`](screenshots/wk13_boiler_ctf_03.png) | Step 2 | FTP anonymous login — `.info.txt` download |
| 4 | [`wk13_boiler_ctf_04.png`](screenshots/wk13_boiler_ctf_04.png) | Step 2 | ROT13 decoded — red herring message |
| 5 | [`wk13_boiler_ctf_05.png`](screenshots/wk13_boiler_ctf_05.png) | Step 3 | Gobuster directory brute-force — `/joomla/` found |
| 6 | [`wk13_boiler_ctf_06.png`](screenshots/wk13_boiler_ctf_06.png) | Step 4 | JoomScan — Joomla 3.9.10 fingerprint |
| 7 | [`wk13_boiler_ctf_07.png`](screenshots/wk13_boiler_ctf_07.png) | Step 4 | JoomScan report — no core vulnerabilities |
| 8 | [`wk13_boiler_ctf_08.png`](screenshots/wk13_boiler_ctf_08.png) | Step 5 | Sar2HTML 3.2.1 — `plot=;id` RCE proof |
| 9 | [`wk13_boiler_ctf_09.png`](screenshots/wk13_boiler_ctf_09.png) | Step 5 | Sar2HTML — `plot=;ls` directory listing |
| 10 | [`wk13_boiler_ctf_10.png`](screenshots/wk13_boiler_ctf_10.png) | Step 5 | `cat log.txt` — credentials in log file |
| 11 | [`wk13_boiler_ctf_11.png`](screenshots/wk13_boiler_ctf_11.png) | Step 6 | SSH login as `basterd` on port 55007 |
| 12 | [`wk13_boiler_ctf_12.png`](screenshots/wk13_boiler_ctf_12.png) | Step 7 | `cat backup.sh` — `stoner` credentials leaked |
| 13 | [`wk13_boiler_ctf_13.png`](screenshots/wk13_boiler_ctf_13.png) | Step 7 | `su stoner` — lateral movement successful |
| 14 | [`wk13_boiler_ctf_14.png`](screenshots/wk13_boiler_ctf_14.png) | Step 8 | User flag — `/home/stoner/.secret` |
| 15 | [`wk13_boiler_ctf_15.png`](screenshots/wk13_boiler_ctf_15.png) | Step 9 | SUID enumeration — `/usr/bin/find` highlighted |
| 16 | [`wk13_boiler_ctf_16.png`](screenshots/wk13_boiler_ctf_16.png) | Step 10 | `find -exec /bin/sh -p` — root shell obtained |
| 17 | [`wk13_boiler_ctf_17.png`](screenshots/wk13_boiler_ctf_17.png) | Step 10 | `id` showing `euid=0(root)` |
| 18 | [`wk13_boiler_ctf_18.png`](screenshots/wk13_boiler_ctf_18.png) | Step 11 | Root flag — `/root/root.txt` |
| 19 | [`wk13_boiler_ctf_19.png`](screenshots/wk13_boiler_ctf_19.png) | Step 11 | TryHackMe room completion |
| 20 | [`wk13_boiler_ctf_20.png`](screenshots/wk13_boiler_ctf_20.png) | Completion | Room progress screen |
| 21 | [`wk13_boiler_ctf_21.png`](screenshots/wk13_boiler_ctf_21.png) | Completion | Final summary |

---

## Week 13 — ETH Final Exam (Unique Screenshots)

| # | File | Description |
|---|------|-------------|
| 1 | [`wk13_eth_final_exam_01.png`](screenshots/wk13_eth_final_exam_01.png) | Final exam — unique screenshot 1 |
| 2 | [`wk13_eth_final_exam_02.png`](screenshots/wk13_eth_final_exam_02.png) | Final exam — unique screenshot 2 |

> 18 additional screenshots from the ETH Final Exam were identical to Boiler CTF screenshots and have been deduplicated.

---

## Week 13 — OWASP Top 10

| # | File | Description |
|---|------|-------------|
| 1 | [`wk13_owasp_top10_01.png`](screenshots/wk13_owasp_top10_01.png) | OWASP Top 10 reference material |

---

## Extraction Metadata

- **Source:** Student DOCX submissions from OneDrive (13 documents)
- **Extraction tool:** `scripts/extract_docx_images.py`
- **Deduplication:** 18 duplicates removed between ETH Final Exam and Boiler CTF
- **Minimum size filter:** 80×80 pixels (skipped decorative elements)
- **Format:** All images converted to PNG for consistency
- **Naming convention:** `wkNN_topic_slug_NN.png`

---

Back to [course README](README.md) · [screenshots/](screenshots/)
