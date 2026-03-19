#!/usr/bin/env python3
import argparse
import re
from collections import defaultdict
from pathlib import Path
from scripts.portfolio._util import load_config, ensure_parent


def humanize_topic(topic: str) -> str:
    t = topic.replace('_', ' ').replace('-', ' ').strip()
    return t.capitalize()


def group_screenshots(screenshots_dir: Path):
    groups = defaultdict(list)
    if not screenshots_dir.exists():
        return groups
    pat = re.compile(r"^wk(\d+)_([a-z0-9\-]+)_", re.IGNORECASE)
    for p in sorted(screenshots_dir.glob('*')):
        if not p.is_file() or p.suffix.lower() not in {'.png', '.jpg', '.jpeg'}:
            continue
        name = p.name
        m = pat.match(name)
        if m:
            week = m.group(1)
            topic = humanize_topic(m.group(2))
            key = f"Week {week} — {topic}"
        elif name.lower().startswith('screenshot'):
            key = 'General — Screenshots'
        else:
            key = 'Miscellaneous'
        groups[key].append(name)
    return groups


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--config", required=True)
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get("course_path", "CC/Your Term/Your Course")
    screenshots = root / course_path / "screenshots"
    out = root / course_path / "EVIDENCE_INDEX.md"

    lines = [
        "# Evidence & Screenshots Index",
        "",
        "This guide groups screenshots by week/topic and links each image with a short caption.",
        "",
    ]

    groups = group_screenshots(screenshots)
    if not groups:
        lines.append("_No screenshots directory found._")
    else:
        def caption_for(name: str) -> str:
            low = name.lower()
            if 'labsetup' in low:
                return 'Lab topology and VM setup verification'
            if 'opnsense' in low:
                return 'OPNsense dashboard/rules configuration'
            if 'lab6' in low:
                return 'Week 10 Lab 6 remediation/validation'
            if 'nessus' in low:
                return 'Nessus scan results/evidence'
            if 'nmap' in low:
                return 'Nmap validation/evidence'
            if 'openvas' in low:
                return 'OpenVAS/Greenbone evidence'
            if 'manageengine' in low or 'endpoint' in low:
                return 'Endpoint Central patch/config evidence'
            if 'wazuh' in low:
                return 'Wazuh SIEM dashboard/alerts'
            return 'Evidence snapshot'

        for section in sorted(groups.keys(), key=lambda s: (s.startswith('Misc'), s)):
            lines.append(f"## {section}")
            for name in groups[section]:
                cap = caption_for(name)
                lines.append(f"- [{name}](screenshots/{name}) — {cap}")
            lines.append("")

    ensure_parent(out)
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()

