#!/usr/bin/env python3
import argparse, json, subprocess

def run(cmd):
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return p.returncode, p.stdout, p.stderr

ap = argparse.ArgumentParser(add_help=False)
ap.add_argument('--roadmap', required=True)
ap.add_argument('--repo', required=True)
ap.add_argument('--json', dest='json_path')
args = ap.parse_args()

with open(args.json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

items = []
for section, lst in data.get('sections', {}).items():
    for it in lst:
        items.append((section, it['line'], it['text'], it['checked']))

created = 0
for section, line, text, checked in items:
    rid = f"{args.roadmap}#L{line}"
    # search existing
    code, out, err = run(["gh","issue","list","-R",args.repo,"--state","all","--search",f'"roadmap-id: {rid}"',"--json","number,title"])
    number = None
    if code == 0:
        arr = json.loads(out or '[]')
        if arr:
            number = arr[0]['number']
    title = text[:120]
    lane = 'lane:now' if 'Now' in section else ('lane:next' if 'Next' in section else ('lane:later' if 'Later' in section else 'lane:unspecified'))
    # Derive a pilot label from repo name (expects NNN-slug)
    repo_name = args.repo.split('/')[-1]
    slug = repo_name.split('-', 1)[1] if '-' in repo_name else repo_name
    pilot = f'pilot:{slug}'
    body = f"Auto-synced from ROADMAP.md\n\nroadmap-id: {rid}\nsection: {section}"
    if number is None:
        cmd = ["gh","issue","create","-R",args.repo,"-t",title,"-b",body,"-l","roadmap","-l",lane,"-l",pilot]
        c,o,e = run(cmd)
        if c==0: created+=1
    else:
        run(["gh","issue","edit",str(number),"-R",args.repo,"-t",title,"-b",body,"--add-label",lane,"--add-label","roadmap","--add-label",pilot])

print(f"SYNC:OK created={created}")
