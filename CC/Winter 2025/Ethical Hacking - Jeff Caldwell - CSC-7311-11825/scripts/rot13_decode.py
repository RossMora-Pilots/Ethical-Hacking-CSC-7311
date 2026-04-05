#!/usr/bin/env python3
"""rot13_decode.py — Quick ROT13 encoder/decoder for CTF hint files.

The Boiler CTF (Week 13) placed a ROT13-encoded message in .info.txt
on the anonymous FTP server. This helper decodes (or encodes — ROT13
is its own inverse) any text passed via argument or stdin.

Usage:
    ./rot13_decode.py "Gur jrneqb vf yvxr n..."
    echo "encoded text" | ./rot13_decode.py
    ./rot13_decode.py < .info.txt

Author: Ross Moravec
Date:   2025-04-14 (Week 13 — Boiler CTF)
"""

import codecs
import sys


def rot13(text: str) -> str:
    """Apply ROT13 transformation (self-inverse)."""
    return codecs.decode(text, "rot_13")


def main() -> None:
    if len(sys.argv) > 1:
        plaintext = " ".join(sys.argv[1:])
    elif not sys.stdin.isatty():
        plaintext = sys.stdin.read()
    else:
        print("Usage: rot13_decode.py <text>", file=sys.stderr)
        print("       echo 'text' | rot13_decode.py", file=sys.stderr)
        sys.exit(1)

    result = rot13(plaintext.strip())
    print(result)


if __name__ == "__main__":
    main()
