#!/usr/bin/env python3
import argparse
from pathlib import Path
from scripts.portfolio._util import load_config, insert_or_replace_block


def build_assignments_index(course_dir: Path) -> str:
    assg = course_dir / "assignments"
    items = []
    if assg.exists():
        for f in sorted(assg.glob("*.pdf"), key=lambda p: p.name.lower()):
            items.append(f"- [{f.name}](assignments/{f.name})")
    return "\n".join(items)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--config", required=True)
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get("course_path")
    if not course_path:
        return
    course_dir = root / course_path
    readme = course_dir / "README.md"
    if not readme.exists():
        return

    index_body = build_assignments_index(course_dir)
    text = readme.read_text(encoding="utf-8")
    start = "<!-- AUTO-GENERATED: Assignments Index START -->"
    end = "<!-- AUTO-GENERATED: Assignments Index END -->"
    new_text, changed = insert_or_replace_block(text, start, end, index_body)
    if changed:
        readme.write_text(new_text, encoding="utf-8")


if __name__ == "__main__":
    main()

