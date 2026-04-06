#!/usr/bin/env python3
"""nmap_parser.py — Parse Nmap XML output into a clean summary table.

Reads an Nmap XML file produced with the -oX flag and prints a formatted
table of discovered hosts, open ports, protocols, services, and versions.

Usage:
    python3 nmap_parser.py scan_results.xml
    python3 nmap_parser.py -f scan_results.xml

Author: Ross Moravec
Date:   2025-04
"""

import argparse
import sys
import xml.etree.ElementTree as ET


def parse_nmap_xml(path: str) -> list[dict]:
    """Return a list of port records from an Nmap XML file."""
    try:
        tree = ET.parse(path)
    except FileNotFoundError:
        sys.exit(f"Error: file not found — {path}")
    except ET.ParseError as exc:
        sys.exit(f"Error: invalid XML — {exc}")

    root = tree.getroot()
    records: list[dict] = []

    for host in root.findall("host"):
        addr_el = host.find("address")
        ip = addr_el.get("addr", "unknown") if addr_el is not None else "unknown"

        hostname = ""
        hostnames_el = host.find("hostnames")
        if hostnames_el is not None:
            hn = hostnames_el.find("hostname")
            if hn is not None:
                hostname = hn.get("name", "")

        display = f"{ip} ({hostname})" if hostname else ip

        ports_el = host.find("ports")
        if ports_el is None:
            continue
        for port in ports_el.findall("port"):
            state_el = port.find("state")
            svc_el = port.find("service")
            records.append({
                "host": display,
                "port": port.get("portid", ""),
                "proto": port.get("protocol", ""),
                "state": state_el.get("state", "") if state_el is not None else "",
                "service": svc_el.get("name", "") if svc_el is not None else "",
                "version": _version_str(svc_el) if svc_el is not None else "",
            })

    return records


def _version_str(svc: ET.Element) -> str:
    """Build a human-readable version string from an Nmap <service> element."""
    parts = [svc.get("product", ""), svc.get("version", ""), svc.get("extrainfo", "")]
    return " ".join(p for p in parts if p)


def print_table(records: list[dict]) -> None:
    """Print records as an aligned ASCII table."""
    if not records:
        print("No open ports found.")
        return

    headers = {"host": "Host", "port": "Port", "proto": "Proto",
               "state": "State", "service": "Service", "version": "Version"}
    widths = {k: len(v) for k, v in headers.items()}
    for rec in records:
        for k in widths:
            widths[k] = max(widths[k], len(rec[k]))

    fmt = "  ".join(f"{{:<{widths[k]}}}" for k in headers)
    print(fmt.format(*headers.values()))
    print(fmt.format(*("-" * widths[k] for k in headers)))
    for rec in records:
        print(fmt.format(*(rec[k] for k in headers)))


def main() -> None:
    parser = argparse.ArgumentParser(description="Parse Nmap XML output into a summary table.")
    parser.add_argument("file", nargs="?", help="Path to Nmap XML file")
    parser.add_argument("-f", "--file-alt", dest="file_alt", help="Alternate flag for input file")
    args = parser.parse_args()

    path = args.file or args.file_alt
    if not path:
        parser.print_help()
        sys.exit(1)

    records = parse_nmap_xml(path)
    print_table(records)


if __name__ == "__main__":
    main()
