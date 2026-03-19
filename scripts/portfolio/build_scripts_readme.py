#!/usr/bin/env python3
import argparse
import re
import shutil
import subprocess
from pathlib import Path
from scripts.portfolio._util import load_config, ensure_parent


def extract_metadata(p: Path, max_lines: int = 15):
    try:
        lines = p.read_text(encoding="utf-8", errors="ignore").splitlines()
    except Exception:
        return {"desc": "", "usage": []}
    comments = []
    usage = []
    for line in lines:
        s = line.strip()
        if p.suffix.lower() != ".ps1" and s.startswith("#!/"):
            continue
        if s.startswith('#'):
            body = s.lstrip('#').strip()
            comments.append(body)
            m = re.match(r"(?i)usage\s*:\s*(.+)", body)
            if m:
                usage.append(m.group(1))
        elif s == "":
            continue
        else:
            break
        if len(comments) >= max_lines:
            break
    desc = " ".join(comments).strip()
    return {"desc": desc, "usage": usage}


def bash_syntax_ok(p: Path) -> bool:
    if p.suffix.lower() != ".sh":
        return True
    bash = shutil.which("bash")
    if not bash:
        return True
    try:
        subprocess.run([bash, "-n", str(p)], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except subprocess.CalledProcessError:
        return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--config", required=True)
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get("course_path", "CC/Your Term/Your Course")
    scripts_dir = root / course_path / "scripts"
    extra_dir = root / course_path / "scripts-extra"
    out = root / course_path / "SCRIPTS_README.md"

    lines = [
        "# Scripts — Usage and Notes",
        "",
        "This document summarizes the purpose and basic usage of each script.",
        "",
    ]

    def handle_dir(d: Path, title: str):
        lines.append(f"## {title}")
        if not d.exists():
            lines.append("_No scripts found._\n")
            return
        for p in sorted(d.glob("*")):
            if p.is_file() and p.suffix.lower() in {".sh", ".ps1"}:
                meta = extract_metadata(p)
                ok = bash_syntax_ok(p)
                status = "OK" if ok else "Syntax error (bash -n)"
                desc = meta["desc"] or 'No description'
                lines.append(f"- `{p.name}` — {desc} — [{status}]")
                if meta["usage"]:
                    lines.append("  ")
                    lines.append("  Usage:")
                    for u in meta["usage"]:
                        lines.append(f"  - `{u}`")
        lines.append("")

    handle_dir(scripts_dir, "Student-Created Scripts (scripts/)")
    handle_dir(extra_dir, "Provided/External Scripts (scripts-extra/)")

    lines.append("\nSafety: Review scripts before running; test in lab VMs. Use with appropriate privileges.")

    ensure_parent(out)
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()

