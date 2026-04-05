#!/usr/bin/env python3
"""Remove duplicate screenshots and renumber gaps."""
import hashlib
from pathlib import Path

screenshots_dir = Path(r"D:\pilots\409-Ethical-Hacking\CC\Winter 2025\Ethical Hacking - Jeff Caldwell - CSC-7311-11825\screenshots")

hashes = {}
removed = []
for f in sorted(screenshots_dir.glob("*.png")):
    h = hashlib.md5(f.read_bytes()).hexdigest()
    if h in hashes:
        f.unlink()
        removed.append(f.name)
    else:
        hashes[h] = f

print(f"Removed {len(removed)} duplicates, {len(hashes)} unique remain")

# Renumber eth_final_exam to be sequential
eth_files = sorted(screenshots_dir.glob("wk13_eth_final_exam_*.png"))
for i, f in enumerate(eth_files, 1):
    new_name = f"wk13_eth_final_exam_{i:02d}.png"
    if f.name != new_name:
        f.rename(screenshots_dir / new_name)
        print(f"  Renamed {f.name} -> {new_name}")

print(f"ETH final exam: {len(eth_files)} unique screenshots")
total = len(list(screenshots_dir.glob("*.png")))
print(f"Total files: {total} PNGs")
