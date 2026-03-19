#!/usr/bin/env python3
import argparse
import os
from pathlib import Path
from scripts.portfolio._util import load_config, insert_or_replace_block, ensure_parent


def build_quick_start(course_path: str) -> str:
    return f"""
🚀 QUICK START FOR HIRING MANAGERS

If you have 5 minutes:
→ Read: Key Achievements (below)
→ View: screenshots in `{course_path}/screenshots/`

If you have 15 minutes:
→ Explore: Midterm and Final in `{course_path}`
→ Review: Scripts in `{course_path}/scripts/`

If you have 30 minutes:
→ Deep dive: Weeks 4–7 hardening, SIEM/vuln work
""".strip()


def build_achievements(cfg: dict) -> str:
    m = cfg.get("metrics", {})
    lines = [
        "**Quantified Results:**",
        "",
        f"• Course Grade: {m.get('grade','N/A')}/100",
        f"• Vulnerability Remediation Rate: {m.get('remediation_rate','N/A')}%",
        f"• Systems Hardened: {m.get('systems_hardened','N/A')} VMs",
        f"• GPO Policies Configured: {m.get('gpo_count','N/A')}+",
        "",
        "Tools: Nessus, Nmap, Wazuh, AD/GPO, OPNsense, Bash, PowerShell",
    ]
    return "\n".join(lines)


def build_navigation(course_path: str) -> str:
    return f"""
📁 How to Review This Portfolio

Network Defense Course → `{course_path}`
• Start Here: `{course_path}/README.md`
• Assignments: `{course_path}/assignments/` (PDFs)
• Scripts: `{course_path}/scripts/` and `scripts-extra/`
• Evidence: `{course_path}/screenshots/`
""".strip()


def build_skills(cfg: dict) -> str:
    skills = cfg.get("skills", []) or [
        "Network Security", "Active Directory/GPO", "Vulnerability Management",
        "SIEM (Wazuh)", "Bash", "PowerShell",
    ]
    return "\n".join(f"- {s}" for s in skills)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--config", required=True)
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get("course_path", "CC/Your Term/Your Course")

    readme = root / "README.md"
    text = readme.read_text(encoding="utf-8") if readme.exists() else "# Course Portfolio\n\n"

    # Optionally inject CI badges block at the top if workflows exist
    repo_slug = os.getenv("REPO_SLUG") or os.getenv("GITHUB_REPOSITORY") or "<owner>/<repo>"
    workflows = [
        ("pm-evidence.yml", "PM Evidence"),
        ("markdownlint.yml", "Markdown Lint"),
        ("gitleaks.yml", "Gitleaks"),
        ("portfolio-ci.yml", "Portfolio CI"),
    ]
    existing = []
    for fname, label in workflows:
        if (root / ".github" / "workflows" / fname).exists():
            badge = f"[![{label}](https://github.com/{repo_slug}/actions/workflows/{fname}/badge.svg)](https://github.com/{repo_slug}/actions/workflows/{fname})"
            existing.append(badge)
    if existing:
        badges_body = " ".join(existing)
        start = "<!-- PORTFOLIO: BADGES START -->"
        end = "<!-- PORTFOLIO: BADGES END -->"
        if start in text and end in text:
            pre, rest = text.split(start, 1)
            _, post = rest.split(end, 1)
            text = pre + start + "\n" + badges_body + "\n" + end + post
        else:
            # Prepend badges to the top of the README
            text = f"{start}\n{badges_body}\n{end}\n\n" + text

    sections = [
        ("<!-- PORTFOLIO: QUICK_START START -->", "<!-- PORTFOLIO: QUICK_START END -->", build_quick_start(course_path)),
        ("<!-- PORTFOLIO: ACHIEVEMENTS START -->", "<!-- PORTFOLIO: ACHIEVEMENTS END -->", build_achievements(cfg)),
        ("<!-- PORTFOLIO: NAVIGATION START -->", "<!-- PORTFOLIO: NAVIGATION END -->", build_navigation(course_path)),
        ("<!-- PORTFOLIO: SKILLS START -->", "<!-- PORTFOLIO: SKILLS END -->", build_skills(cfg)),
    ]

    changed = False
    for start, end, body in sections:
        text, c = insert_or_replace_block(text, start, end, body)
        changed = changed or c

    if changed:
        ensure_parent(readme)
        readme.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()
