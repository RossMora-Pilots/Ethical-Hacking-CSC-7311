#!/usr/bin/env python3
import sys, json, re
from pathlib import Path

def parse_markdown(path: Path):
    text = path.read_text(encoding='utf-8', errors='ignore')
    lines = text.splitlines()
    heading_stack = []
    items = []
    h = re.compile(r'^(#{1,6})\s+(.*)')
    c = re.compile(r'^\s*[-*]\s*\[( |x|X)\]\s+(.*)$')
    def section():
        return "/".join([t for _,t in heading_stack])
    for ln, line in enumerate(lines, start=1):
        m = h.match(line)
        if m:
            level = len(m.group(1)); title = m.group(2).strip()
            while heading_stack and heading_stack[-1][0] >= level:
                heading_stack.pop()
            heading_stack.append((level, title)); continue
        m = c.match(line)
        if m:
            items.append({"line": ln, "checked": m.group(1).lower()=="x", "text": m.group(2).strip(), "section": section()})
    sections = {}
    for it in items: sections.setdefault(it["section"], []).append(it)
    return {"path": str(path), "items_total": len(items), "items_done": sum(1 for i in items if i["checked"]), "sections": sections}

def main():
    if len(sys.argv) < 2: print("Usage: parse_roadmap.py <roadmap_path> [--out OUT]", file=sys.stderr); sys.exit(2)
    roadmap = Path(sys.argv[1]); out = None
    if "--out" in sys.argv:
        i = sys.argv.index("--out"); out = Path(sys.argv[i+1]) if i+1 < len(sys.argv) else None
    data = parse_markdown(roadmap); j = json.dumps(data, indent=2, ensure_ascii=False)
    if out:
        out.parent.mkdir(parents=True, exist_ok=True); out.write_text(j, encoding='utf-8')
    else:
        print(j)

if __name__ == '__main__':
    main()

