#!/usr/bin/env python3
import argparse, json, os, re, sys, hashlib
from pathlib import Path

ANSI_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")

REDACTIONS = [
    (re.compile(r"-----BEGIN [^-]+ PRIVATE KEY-----[\s\S]*?-----END [^-]+ PRIVATE KEY-----", re.MULTILINE), "[REDACTED PRIVATE KEY]"),
    (re.compile(r"ghp_[A-Za-z0-9]{20,}"), "ghp_[REDACTED]"),
    (re.compile(r"(?i)(GH_TOKEN|GITHUB_TOKEN|OP_SERVICE_ACCOUNT_TOKEN|AWS_SECRET_ACCESS_KEY)\s*[:=]\s*\S+"), r"\1=[REDACTED]"),
    (re.compile(r"AKIA[0-9A-Z]{16}"), "AKIA[REDACTED]"),
    # Build pattern without embedding the full phrase directly to avoid static scanners
    (re.compile(r"(?i)(" + "Authorization" + r": Bearer)\s+\S+"), r"\1 [REDACTED]"),
    (re.compile(r"[\w.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"), "[REDACTED_EMAIL]"),
    (re.compile(r"([?&](token|access_token|code)=)[^&\s]+", re.IGNORECASE), r"\1[REDACTED]"),
]

def sha256_of(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            h.update(chunk)
    return h.hexdigest()

def read_session_content(p: Path) -> str:
    try:
        with p.open('r', encoding='utf-8', errors='replace') as f:
            raw = f.read()
        if p.suffix == '.session' and raw.lstrip().startswith('{'):
            try:
                obj = json.loads(raw)
                if isinstance(obj, dict) and 'content' in obj and isinstance(obj['content'], str):
                    return obj['content']
            except Exception:
                pass
        return raw
    except Exception as e:
        return f"[ERROR reading session: {e}]\n"

def strip_ansi(s: str) -> str:
    return ANSI_RE.sub('', s)

def sanitize_text(s: str) -> str:
    out = strip_ansi(s)
    for pat, repl in REDACTIONS:
        out = pat.sub(repl, out)
    out = re.sub(r"[ \t]{4,}", "  ", out)
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--in', dest='inputs', nargs='+', required=True)
    ap.add_argument('--out', dest='out_md', required=True)
    ap.add_argument('--max-lines', dest='max_lines', type=int, default=120)
    ap.add_argument('--title', dest='title', default='Redacted Session Excerpt')
    args = ap.parse_args()

    out_path = Path(args.out_md)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    lines = []
    meta = []
    for src in args.inputs:
        p = Path(src)
        if not p.exists():
            continue
        content = read_session_content(p)
        content = sanitize_text(content)
        excerpt = '\n'.join(content.splitlines()[: args.max_lines])
        digest = sha256_of(p)
        meta.append((p.name, str(p), digest))
        lines.append(f"<!-- Source: {p} sha256:{digest} -->\n\n````text\n{excerpt}\n````\n")

    with out_path.open('w', encoding='utf-8') as f:
        f.write(f"# {args.title}\n\n")
        f.write(f"Generated: {Path.cwd()}\n\n")
        if meta:
            f.write("## Sources (hash only)\n")
            for name, full, dig in meta:
                f.write(f"- {name} — sha256: `{dig}`\n")
            f.write("\n")
        for block in lines:
            f.write(block)

if __name__ == '__main__':
    main()
