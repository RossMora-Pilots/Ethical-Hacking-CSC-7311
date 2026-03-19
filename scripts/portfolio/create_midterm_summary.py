#!/usr/bin/env python3
import argparse
from pathlib import Path
from scripts.portfolio._util import load_config, ensure_parent


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--config", required=True)
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get("course_path", "CC/Your Term/Your Course")
    out = root / course_path / "MIDTERM_PROJECT_SUMMARY.md"
    if out.exists() and not args.force:
        return
    tpl = (root / "templates" / "MIDTERM_PROJECT_SUMMARY.md.tpl").read_text(encoding="utf-8")
    ensure_parent(out)
    out.write_text(tpl, encoding="utf-8")


if __name__ == "__main__":
    main()

