#!/usr/bin/env python3
import argparse, hashlib
from pathlib import Path

p = argparse.ArgumentParser(add_help=False)
p.add_argument('--root', required=True)
p.add_argument('--out', required=True)
a = p.parse_args()
root = Path(a.root); out = Path(a.out)
rows = []
sd = root / 'sessions'
if sd.exists():
    for m in sorted(sd.rglob('*.md')):
        h = hashlib.sha256(m.read_bytes()).hexdigest()
        rows.append((m.relative_to(root).as_posix(), m.stat().st_size, h))
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('w', encoding='utf-8') as f:
    f.write('# Sessions Index\n\n')
    if not rows:
        f.write('_No sessions found._\n')
    else:
        for rel, size, h in rows:
            f.write(f'- {rel} ({size} bytes) — sha256: `{h}`\n')
print(f'INDEX:OK:{a.out} ({len(rows)} entries)')

