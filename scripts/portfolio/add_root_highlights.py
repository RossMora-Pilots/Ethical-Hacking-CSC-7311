#!/usr/bin/env python3
import argparse
from pathlib import Path

BLOCK = """
## Highlights
- Midterm Project Summary → CC/Your Term/Your Course/MIDTERM_PROJECT_SUMMARY.md
- Final Exam: Vulnerability Assessment → CC/Your Term/Your Course/FINAL_EXAM_VULNERABILITY_ASSESSMENT.md
- Scripts Overview → CC/Your Term/Your Course/SCRIPTS_README.md
""".strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', required=True)
    args = ap.parse_args()
    root = Path(args.root)
    readme = root / 'README.md'
    if not readme.exists():
        return
    s = readme.read_text(encoding='utf-8')
    if '## Highlights' in s:
        return
    anchor = '## Start Here'
    idx = s.find(anchor)
    if idx == -1:
        anchor = '## Quick Links'
        idx = s.find(anchor)
    if idx != -1:
        end = s.find('\n', idx)
        s = s[:end+1] + s[end+1:] + BLOCK + '\n'
    else:
        s = s.rstrip() + '\n\n' + BLOCK + '\n'
    readme.write_text(s, encoding='utf-8')


if __name__ == '__main__':
    main()

