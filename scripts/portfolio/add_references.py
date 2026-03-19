#!/usr/bin/env python3
import argparse
from pathlib import Path
from scripts.portfolio._util import load_config, insert_or_replace_block


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--config", required=True)
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get("course_path", "CC/Your Term/Your Course")
    refs = cfg.get("references", [])
    if not refs:
        return
    readme = root / course_path / "README.md"
    if not readme.exists():
        return
    body_lines = ["- [{}]({})".format(r.get("title","Reference"), r.get("url","#")) for r in refs]
    body = "\n".join(body_lines)
    start = "<!-- PORTFOLIO: REFERENCES START -->"
    end = "<!-- PORTFOLIO: REFERENCES END -->"
    text = readme.read_text(encoding='utf-8')
    new_text, changed = insert_or_replace_block(text, start, end, body)
    if changed:
        readme.write_text(new_text, encoding='utf-8')


if __name__ == "__main__":
    main()

