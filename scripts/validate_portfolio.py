#!/usr/bin/env python3
"""Comprehensive portfolio validation script."""
import re
import yaml
from pathlib import Path

BASE = Path(r"D:\pilots\409-Ethical-Hacking")
CC = BASE / "CC" / "Winter 2025" / "Ethical Hacking - Jeff Caldwell - CSC-7311-11825"

errors = []
warnings = []
passes = []

# ── 1. Validate image references in CTF walkthroughs ──
print("=" * 60)
print("1. IMAGE REFERENCE VALIDATION")
print("=" * 60)
for md_file in sorted(CC.glob("ctf-walkthroughs/*.md")):
    content = md_file.read_text(encoding="utf-8")
    img_count = 0
    for i, line in enumerate(content.split("\n"), 1):
        for m in re.finditer(r"!\[([^\]]*)\]\(([^)]+)\)", line):
            ref = m.group(2)
            if ref.startswith("http"):
                continue
            img_count += 1
            target = (md_file.parent / ref).resolve()
            if not target.exists():
                errors.append(f"BROKEN IMG: {md_file.name}:{i} -> {ref}")
                print(f"  FAIL {md_file.name}:{i} -> {ref}")
    if img_count > 0:
        passes.append(f"{md_file.name}: {img_count} image refs OK")
        print(f"  PASS {md_file.name}: {img_count} image refs valid")
    else:
        warnings.append(f"{md_file.name}: NO image references found")
        print(f"  WARN {md_file.name}: no image references")

# ── 2. Validate all internal markdown links ──
print()
print("=" * 60)
print("2. INTERNAL LINK VALIDATION")
print("=" * 60)
for md_file in sorted(CC.rglob("*.md")):
    content = md_file.read_text(encoding="utf-8")
    for i, line in enumerate(content.split("\n"), 1):
        for m in re.finditer(r"(?<!!)\[([^\]]*)\]\(([^)]+)\)", line):
            ref = m.group(2)
            if ref.startswith("http") or ref.startswith("#") or ref.startswith("mailto:"):
                continue
            # Strip anchor from path
            path_part = ref.split("#")[0]
            if not path_part:
                continue
            target = (md_file.parent / path_part).resolve()
            if not target.exists():
                rel = md_file.relative_to(CC)
                errors.append(f"BROKEN LINK: {rel}:{i} -> {ref}")
                print(f"  FAIL {rel}:{i} -> {ref}")

if not any("BROKEN LINK" in e for e in errors):
    passes.append("All internal markdown links resolve")
    print("  PASS All internal markdown links resolve")

# ── 3. Validate CI workflows ──
print()
print("=" * 60)
print("3. CI WORKFLOW VALIDATION")
print("=" * 60)
for wf in sorted((BASE / ".github" / "workflows").glob("*.yml")):
    try:
        data = yaml.safe_load(wf.read_text(encoding="utf-8"))
        has_name = "name" in data
        has_on = "on" in data or True in data
        has_jobs = "jobs" in data
        issues = []
        if not has_name:
            issues.append("missing name")
        if not has_on:
            issues.append("missing on trigger")
        if not has_jobs:
            issues.append("missing jobs")
        if issues:
            errors.append(f"YAML {wf.name}: {issues}")
            print(f"  FAIL {wf.name}: {issues}")
        else:
            job_names = list(data["jobs"].keys())
            passes.append(f"{wf.name}: valid YAML with jobs {job_names}")
            print(f"  PASS {wf.name}: valid (jobs: {job_names})")
    except Exception as e:
        errors.append(f"YAML {wf.name}: parse error: {e}")
        print(f"  FAIL {wf.name}: {e}")

# ── 4. Mermaid diagram count ──
print()
print("=" * 60)
print("4. MERMAID DIAGRAM COUNT")
print("=" * 60)
mermaid_count = 0
for md_file in sorted(BASE.rglob("*.md")):
    content = md_file.read_text(encoding="utf-8")
    blocks = re.findall(r"```mermaid", content)
    if blocks:
        rel = md_file.relative_to(BASE)
        print(f"  {rel}: {len(blocks)} diagram(s)")
        mermaid_count += len(blocks)
print(f"  TOTAL: {mermaid_count} Mermaid diagrams (claimed: 6)")
if mermaid_count >= 6:
    passes.append(f"Mermaid count: {mermaid_count} (claimed 6)")
else:
    errors.append(f"Mermaid count: {mermaid_count} but claimed 6")

# ── 5. GitHub callout count ──
print()
print("=" * 60)
print("5. GITHUB CALLOUT COUNT")
print("=" * 60)
callout_count = 0
valid_types = {"NOTE", "TIP", "WARNING", "CAUTION", "IMPORTANT"}
for md_file in sorted(BASE.rglob("*.md")):
    content = md_file.read_text(encoding="utf-8")
    callouts = re.findall(r">\s*\[!([\w]+)\]", content)
    if callouts:
        rel = md_file.relative_to(BASE)
        for c in callouts:
            if c not in valid_types:
                errors.append(f"Invalid callout type: {c} in {rel}")
                print(f"  FAIL Invalid callout [{c}] in {rel}")
        print(f"  {rel}: {len(callouts)} callout(s) ({', '.join(callouts)})")
        callout_count += len(callouts)
print(f"  TOTAL: {callout_count} callouts (claimed: 19)")
if callout_count >= 19:
    passes.append(f"Callout count: {callout_count} (claimed 19)")
else:
    warnings.append(f"Callout count: {callout_count} but claimed 19")

# ── 6. Word count on Mr. Robot ──
print()
print("=" * 60)
print("6. MR. ROBOT WORD COUNT")
print("=" * 60)
mr_robot = CC / "ctf-walkthroughs" / "mr-robot-ctf.md"
words = len(mr_robot.read_text(encoding="utf-8").split())
print(f"  Current word count: {words} (claimed: 2144)")
if words >= 2000:
    passes.append(f"Mr. Robot word count: {words}")
else:
    warnings.append(f"Mr. Robot word count: {words} (expected ~2144)")

# ── 7. TOC, Remediation, MITRE in all CTFs ──
print()
print("=" * 60)
print("7. CTF WALKTHROUGH STRUCTURE")
print("=" * 60)
for ctf in ["midterm-pickle-rick.md", "mr-robot-ctf.md", "final-boiler-ctf.md"]:
    content = (CC / "ctf-walkthroughs" / ctf).read_text(encoding="utf-8")
    has_toc = "## Table of Contents" in content
    has_remed = "CVSS" in content
    has_mitre = "MITRE ATT&CK" in content
    has_owasp = "OWASP" in content
    status = "PASS" if all([has_toc, has_remed, has_mitre, has_owasp]) else "WARN"
    print(f"  {status} {ctf}: TOC={has_toc} CVSS={has_remed} MITRE={has_mitre} OWASP={has_owasp}")
    if not has_toc:
        warnings.append(f"{ctf}: missing Table of Contents")
    if not has_remed:
        warnings.append(f"{ctf}: missing CVSS remediation")
    if not has_mitre:
        warnings.append(f"{ctf}: missing MITRE ATT&CK mapping")

# ── 8. CI badge validation ──
print()
print("=" * 60)
print("8. CI BADGE VALIDATION")
print("=" * 60)
readme = (BASE / "README.md").read_text(encoding="utf-8")
badge_pattern = re.findall(r"\[!\[([^\]]+)\]\(([^)]+)\)", readme)
for name, url in badge_pattern:
    # Extract workflow file from badge URL
    wf_match = re.search(r"/actions/workflows/([^/]+)", url)
    if wf_match:
        wf_file = wf_match.group(1)
        wf_path = BASE / ".github" / "workflows" / wf_file
        if wf_path.exists():
            passes.append(f"Badge '{name}' -> {wf_file} exists")
            print(f"  PASS Badge '{name}' -> {wf_file}")
        else:
            errors.append(f"Badge '{name}' -> {wf_file} MISSING")
            print(f"  FAIL Badge '{name}' -> {wf_file} NOT FOUND")

# ── 9. Screenshot count vs EVIDENCE_INDEX claim ──
print()
print("=" * 60)
print("9. SCREENSHOT COUNT CONSISTENCY")
print("=" * 60)
actual_pngs = len(list((CC / "screenshots").glob("*.png")))
evidence_content = (CC / "EVIDENCE_INDEX.md").read_text(encoding="utf-8")
claimed_match = re.search(r"\*\*(\d+) unique screenshots\*\*", evidence_content)
claimed = int(claimed_match.group(1)) if claimed_match else 0
print(f"  Actual PNGs on disk: {actual_pngs}")
print(f"  EVIDENCE_INDEX claims: {claimed}")
if actual_pngs == claimed:
    passes.append(f"Screenshot count consistent: {actual_pngs}")
    print(f"  PASS Consistent")
else:
    errors.append(f"Screenshot mismatch: disk={actual_pngs} claimed={claimed}")
    print(f"  FAIL Mismatch!")

# ── 10. Week 8 report check ──
print()
print("=" * 60)
print("10. WEEK 8 REPORT")
print("=" * 60)
wk8 = CC / "weekly-reports" / "week-08-midterm-pickle-rick.md"
if wk8.exists():
    wk8_words = len(wk8.read_text(encoding="utf-8").split())
    if wk8_words > 50:
        passes.append(f"Week 8 report: {wk8_words} words")
        print(f"  PASS {wk8_words} words (not a stub)")
    else:
        warnings.append(f"Week 8 report only {wk8_words} words")
        print(f"  WARN Only {wk8_words} words")
else:
    errors.append("Week 8 report MISSING")
    print(f"  FAIL File does not exist")

# ── SUMMARY ──
print()
print("=" * 60)
print("VALIDATION SUMMARY")
print("=" * 60)
print(f"  ✅ PASSES:   {len(passes)}")
for p in passes:
    print(f"     {p}")
print(f"  ⚠️  WARNINGS: {len(warnings)}")
for w in warnings:
    print(f"     {w}")
print(f"  ❌ ERRORS:   {len(errors)}")
for e in errors:
    print(f"     {e}")
print()
if errors:
    print("RESULT: ISSUES FOUND — remediation needed")
else:
    print("RESULT: ALL VALIDATIONS PASSED")
