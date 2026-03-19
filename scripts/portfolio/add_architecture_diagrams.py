#!/usr/bin/env python3
import argparse
from pathlib import Path
from scripts.portfolio._util import load_config


DIAGRAM_MIDTERM = """
### Architecture Diagram
```mermaid
flowchart LR
  Client[Client] --> OPNsense(OPNsense FW)
  OPNsense --> DC[Windows Server 2022 DC]
  OPNsense --> Ubuntu[Ubuntu]
  OPNsense --> CentOS[CentOS]
  Ubuntu --> Wazuh[Wazuh]
  CentOS --> Wazuh
```
```
ASCII
Client -> OPNsense -> DC
                 -> Ubuntu -> Wazuh
                 -> CentOS -> Wazuh
```
""".strip()

DIAGRAM_FINAL = """
### Architecture Diagram
```mermaid
flowchart TB
  Nessus[Nessus/Nmap/OpenVAS] --> Targets[Windows/Linux Targets]
  Targets --> Remediation[Remediation Steps]
  Remediation --> Rescan[Validation Re-Scan]
```
```
ASCII
Scanners -> Targets -> Remediation -> Re-Scan
```
""".strip()


def ensure_block(path: Path, marker: str, content: str):
    s = path.read_text(encoding='utf-8')
    if marker not in s:
        s = s.rstrip() + "\n\n" + content + "\n"
        path.write_text(s, encoding='utf-8')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', required=True)
    ap.add_argument('--config', required=True)
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get('course_path', 'CC/Your Term/Your Course')
    mid = root / course_path / 'MIDTERM_PROJECT_SUMMARY.md'
    fin = root / course_path / 'FINAL_EXAM_VULNERABILITY_ASSESSMENT.md'
    if mid.exists():
        ensure_block(mid, '### Architecture Diagram', DIAGRAM_MIDTERM)
    if fin.exists():
        ensure_block(fin, '### Architecture Diagram', DIAGRAM_FINAL)


if __name__ == '__main__':
    main()

