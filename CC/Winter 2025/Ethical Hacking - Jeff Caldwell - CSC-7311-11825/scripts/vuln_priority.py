#!/usr/bin/env python3
"""vuln_priority.py — Prioritize vulnerabilities by CVSS score.

Reads a CSV with columns id, finding, severity, cvss, cwe, recommendation
and outputs a sorted table (CVSS descending) with severity color indicators.

Usage:
    python3 vuln_priority.py vulns.csv
    cat vulns.csv | python3 vuln_priority.py -

Author: Ross Moravec
Date:   2025-04
"""

import argparse
import csv
import sys

REQUIRED_COLS = {"id", "finding", "severity", "cvss", "cwe", "recommendation"}

SEVERITY_ICON = {
    "critical": "\033[91m██\033[0m",  # bright red
    "high":     "\033[31m██\033[0m",  # red
    "medium":   "\033[33m██\033[0m",  # yellow
    "low":      "\033[32m██\033[0m",  # green
    "info":     "\033[36m██\033[0m",  # cyan
}


def read_vulns(source) -> list[dict]:
    """Read vulnerability rows from a CSV file object."""
    reader = csv.DictReader(source)
    if reader.fieldnames is None:
        sys.exit("Error: empty or headerless CSV.")

    present = {f.strip().lower() for f in reader.fieldnames}
    missing = REQUIRED_COLS - present
    if missing:
        sys.exit(f"Error: missing CSV columns — {', '.join(sorted(missing))}")

    rows: list[dict] = []
    for lineno, row in enumerate(reader, start=2):
        row = {k.strip().lower(): v.strip() for k, v in row.items()}
        try:
            row["cvss"] = float(row["cvss"])
        except (ValueError, KeyError):
            print(f"Warning: skipping line {lineno} — invalid CVSS value.", file=sys.stderr)
            continue
        rows.append(row)

    return rows


def print_table(rows: list[dict]) -> None:
    """Print a formatted, severity-colored table."""
    if not rows:
        print("No vulnerabilities to display.")
        return

    rows.sort(key=lambda r: r["cvss"], reverse=True)

    widths = {
        "id": max(2, *(len(str(r["id"])) for r in rows)),
        "finding": max(7, *(len(r["finding"]) for r in rows)),
        "severity": max(8, *(len(r["severity"]) for r in rows)),
        "cvss": 4,
        "cwe": max(3, *(len(r["cwe"]) for r in rows)),
        "recommendation": max(14, *(len(r["recommendation"]) for r in rows)),
    }

    # Cap recommendation width for readability
    widths["recommendation"] = min(widths["recommendation"], 50)

    hdr = (f"{'':4s}  "
           f"{'ID':<{widths['id']}}  "
           f"{'Finding':<{widths['finding']}}  "
           f"{'Severity':<{widths['severity']}}  "
           f"{'CVSS':>4}  "
           f"{'CWE':<{widths['cwe']}}  "
           f"{'Recommendation':<{widths['recommendation']}}")
    print(hdr)
    print("-" * len(hdr))

    for row in rows:
        sev_key = row["severity"].lower()
        icon = SEVERITY_ICON.get(sev_key, "  ")
        rec = row["recommendation"][:widths["recommendation"]]
        print(f"{icon}  "
              f"{str(row['id']):<{widths['id']}}  "
              f"{row['finding']:<{widths['finding']}}  "
              f"{row['severity']:<{widths['severity']}}  "
              f"{row['cvss']:>4.1f}  "
              f"{row['cwe']:<{widths['cwe']}}  "
              f"{rec:<{widths['recommendation']}}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Prioritize vulnerabilities by CVSS score.")
    parser.add_argument(
        "file", nargs="?", default="-",
        help="CSV file path, or '-' / omit for stdin")
    args = parser.parse_args()

    if args.file == "-":
        rows = read_vulns(sys.stdin)
    else:
        try:
            with open(args.file, newline="", encoding="utf-8") as fh:
                rows = read_vulns(fh)
        except FileNotFoundError:
            sys.exit(f"Error: file not found — {args.file}")

    print_table(rows)


if __name__ == "__main__":
    main()
