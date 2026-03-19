#!/usr/bin/env python3
import argparse
from pathlib import Path
from scripts.portfolio._util import load_config

BLOCK = """
## Learning Reflection
- Iterative remediation beats one-shot fixes: scanning, patching, and re-scanning produced measurable improvements.
- Security vs. usability: tightened policies while preserving required functionality by scoping and testing changes.
- Observability matters: SIEM and scan artifacts enabled evidence-driven decisions and faster troubleshooting.
""".strip()


def ensure_block(path: Path, marker: str, content: str):
    s = path.read_text(encoding='utf-8')
    if marker not in s:
        idx = s.find('\n\n# Appendix')
        if idx != -1:
            s = s[:idx] + '\n\n' + content + s[idx:]
        else:
            s = s.rstrip() + '\n\n' + content + '\n'
        path.write_text(s, encoding='utf-8')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', required=True)
    ap.add_argument('--config', required=True)
    args = ap.parse_args()

    root = Path(args.root)
    cfg = load_config(Path(args.config))
    course_path = cfg.get('course_path', 'CC/Your Term/Your Course')
    readme = root / course_path / 'README.md'
    if readme.exists():
        ensure_block(readme, '## Learning Reflection', BLOCK)


if __name__ == '__main__':
    main()

