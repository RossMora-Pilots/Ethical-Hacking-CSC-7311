#!/usr/bin/env python3
import argparse, json, os, ssl, socket, urllib.request, urllib.error, hashlib, re
from datetime import datetime, timezone
from html.parser import HTMLParser
from urllib.parse import urlparse, urljoin, parse_qs
import xml.etree.ElementTree as ET

DEF_UA = "Mozilla/5.0 (compatible; UWWebScan/1.0)"
TIMEOUT = 12


def ensure_dir(p: str) -> None:
    os.makedirs(p, exist_ok=True)


def fetch(url: str, method: str = "HEAD", timeout: int = TIMEOUT, max_body: int = 0):
    req = urllib.request.Request(url, headers={"User-Agent": DEF_UA}, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = resp.read(max_body) if max_body > 0 else b""
            return {
                "ok": True,
                "final_url": resp.geturl(),
                "status": getattr(resp, "status", None),
                "headers": {k.lower(): v for k, v in resp.getheaders()},
                "body_sample_sha256": hashlib.sha256(data).hexdigest() if data else None,
            }
    except urllib.error.HTTPError as e:
        return {
            "ok": False,
            "final_url": e.geturl(),
            "status": e.code,
            "headers": {k.lower(): v for k, v in e.headers.items()},
            "error": f"HTTPError: {e.code}",
        }
    except Exception as e:
        return {"ok": False, "error": str(e)}


def get_tls_info(host: str, port: int = 443, timeout: int = TIMEOUT):
    ctx = ssl.create_default_context()
    info = {"ok": False}
    try:
        with socket.create_connection((host, port), timeout=timeout) as sock:
            with ctx.wrap_socket(sock, server_hostname=host) as ssock:
                cert = ssock.getpeercert()
                info["ok"] = True
                info["subject"] = cert.get("subject")
                info["issuer"] = cert.get("issuer")
                info["san"] = cert.get("subjectAltName")
                not_after = cert.get("notAfter")
                if not_after:
                    dt = datetime.strptime(not_after, "%b %d %H:%M:%S %Y %Z").replace(tzinfo=timezone.utc)
                    info["not_after"] = dt.isoformat()
                    days = (dt - datetime.now(timezone.utc)).days
                    info["days_until_expiry"] = days
    except Exception as e:
        info["error"] = str(e)
    return info


def resolve_all(host: str):
    ips = set()
    try:
        for fam, _, _, _, sockaddr in socket.getaddrinfo(host, None):
            ip = sockaddr[0]
            ips.add(ip)
    except Exception:
        pass
    return sorted(ips)


def check_security_headers(h: dict):
    present = {
        "strict-transport-security": False,
        "content-security-policy": False,
        "x-frame-options": False,
        "x-content-type-options": False,
        "referrer-policy": False,
        "permissions-policy": False,
    }
    if not isinstance(h, dict):
        return {"present": present, "missing": list(present.keys()), "grade": "D"}
    for k in list(present.keys()):
        present[k] = k in h
    missing = [k for k, v in present.items() if not v]
    grade = (
        "A"
        if present["strict-transport-security"]
        and present["content-security-policy"]
        and present["x-content-type-options"]
        else "B" if len(missing) <= 2 else "C" if len(missing) <= 4 else "D"
    )
    return {"present": present, "missing": missing, "grade": grade}


class SimpleHTMLInventory(HTMLParser):
    def __init__(self, base_url: str | None = None):
        super().__init__()
        self.base_url = base_url
        self.scripts = []  # src
        self.links = []    # rel, href
        self.images = []   # src
        self.forms = []    # action, method
        self.inline_script_blocks = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'script':
            src = attrs.get('src')
            if src:
                self.scripts.append(self._abs(src))
            else:
                self.inline_script_blocks += 1
        elif tag == 'link':
            href = attrs.get('href')
            rel = attrs.get('rel')
            if href:
                self.links.append({"rel": rel, "href": self._abs(href)})
        elif tag == 'img':
            src = attrs.get('src')
            if src:
                self.images.append(self._abs(src))
        elif tag == 'form':
            action = attrs.get('action')
            method = (attrs.get('method') or 'GET').upper()
            self.forms.append({"action": self._abs(action) if action else None, "method": method})

    def _abs(self, url):
        if not url:
            return url
        if self.base_url:
            try:
                return urljoin(self.base_url, url)
            except Exception:
                return url
        return url


def parse_homepage(url: str, timeout: int = TIMEOUT, max_body: int = 2000000):
    # GET homepage bytes
    req = urllib.request.Request(url, headers={"User-Agent": DEF_UA}, method="GET")
    result = {"ok": False}
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read(max_body)
            headers = {k.lower(): v for k, v in resp.getheaders()}
            result.update({
                "ok": True,
                "status": getattr(resp, "status", None),
                "final_url": resp.geturl(),
                "headers": headers,
                "sha256": hashlib.sha256(body).hexdigest(),
                "size": len(body),
            })
            text = body.decode('utf-8', errors='replace')
            inv = SimpleHTMLInventory(base_url=result["final_url"]) if result.get("final_url") else SimpleHTMLInventory()
            inv.feed(text)
            result["inventory"] = {
                "scripts": inv.scripts,
                "links": inv.links,
                "images": inv.images,
                "forms": inv.forms,
                "inline_script_blocks": inv.inline_script_blocks,
                "meta_generator": _extract_meta_generator(text),
            }
            result["third_party_origins"] = sorted(list(_collect_third_party_origins(inv, result.get("final_url"))))
            result["has_mixed_content_refs"] = any(u.startswith('http://') for u in (inv.scripts + [l.get('href') for l in inv.links if isinstance(l, dict) and l.get('href')] + inv.images))
            return result, body
    except Exception as e:
        result["error"] = str(e)
        return result, b""


def _extract_meta_generator(text: str):
    # Simple regex to find <meta name="generator" content="...">
    m = re.search(r'<meta[^>]+name=["\']generator["\'][^>]+content=["\']([^"\']+)["\']', text, re.IGNORECASE)
    return m.group(1) if m else None


def _collect_third_party_origins(inv: SimpleHTMLInventory, base: str | None):
    base_host = urlparse(base).hostname if base else None
    origins = set()
    items = []
    items.extend(inv.scripts)
    items.extend([l.get('href') for l in inv.links if isinstance(l, dict)])
    items.extend(inv.images)
    for u in items:
        try:
            pu = urlparse(u)
            if pu.scheme in ("http", "https"):
                if base_host and pu.hostname and pu.hostname != base_host:
                    origins.add(f"{pu.scheme}://{pu.hostname}")
        except Exception:
            continue
    return origins


def parse_cookies(set_cookie_values: list[str]):
    cookies = []
    for sc in set_cookie_values:
        parts = [p.strip() for p in sc.split(';')]
        if not parts:
            continue
        name_value = parts[0]
        name, _, value = name_value.partition('=')
        flags = {p.lower(): True for p in parts[1:]}
        cookies.append({
            "name": name,
            "has_secure": 'secure' in flags,
            "has_httponly": 'httponly' in flags,
            "samesite": next((p.split('=')[1] for p in parts[1:] if p.lower().startswith('samesite=')), None)
        })
    return cookies


def check_known_endpoints(base_https: str, apex_https: str):
    endpoints = {
        "security_txt": urljoin(base_https + '/', '/.well-known/security.txt'),
        "change_password": urljoin(base_https + '/', '/.well-known/change-password'),
        "wp_login": urljoin(base_https + '/', '/wp-login.php'),
        "wp_json": urljoin(base_https + '/', '/wp-json/'),
        "favicon": urljoin(base_https + '/', '/favicon.ico'),
        "apex_https": apex_https,
        "apex_http": apex_https.replace('https://', 'http://'),
    }
    results = {}
    for k, u in endpoints.items():
        r = fetch(u, method="HEAD")
        if not r.get("ok"):
            r = fetch(u, method="GET", max_body=2048)
        results[k] = {
            "status": r.get("status"),
            "final_url": r.get("final_url"),
            "ok": r.get("ok"),
            "error": r.get("error"),
            "headers": r.get("headers"),
        }
    return results


def parse_sitemap(url: str, timeout: int = TIMEOUT, limit: int = 10):
    try:
        r = urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": DEF_UA}), timeout=timeout)
        xml = r.read(1000000)
        root = ET.fromstring(xml)
        ns = ''
        if root.tag.endswith('urlset'):
            urls = [loc.text.strip() for loc in root.findall('.//{*}loc') if loc.text]
            return urls[:limit]
        elif root.tag.endswith('sitemapindex'):
            maps = [loc.text.strip() for loc in root.findall('.//{*}loc') if loc.text]
            # Fetch first sitemap for brevity
            if maps:
                return parse_sitemap(maps[0], timeout=timeout, limit=limit)
    except Exception:
        return []
    return []


def extract_plugin_slug_from_url(url: str):
    try:
        pu = urlparse(url)
        if pu.scheme not in ("http", "https"):
            return None
        path = pu.path or ""
        # Look for /wp-content/plugins/<slug>/
        marker = "/wp-content/plugins/"
        i = path.find(marker)
        if i == -1:
            return None
        rest = path[i + len(marker):]
        slug = rest.split("/", 1)[0]
        if slug and all(c.isalnum() or c in ('-', '_') for c in slug):
            return slug
    except Exception:
        return None
    return None


def infer_versions_from_urls(urls: list[str]):
    versions = []
    for u in urls:
        try:
            q = parse_qs(urlparse(u).query)
            ver = None
            if 'ver' in q and q['ver']:
                ver = q['ver'][0]
            if ver and _looks_like_semver(ver):
                versions.append(ver)
        except Exception:
            continue
    # Return most common semantic version (avoids picking library sub-dependency versions)
    if not versions:
        return None
    # Choose most frequent value
    best = max(set(versions), key=versions.count)
    return best


def _looks_like_semver(v: str):
    return bool(re.match(r"^\d+(?:\.\d+){1,3}$", v))


def _semver_key(v: str):
    parts = [int(p) for p in v.split('.')[:4]]
    while len(parts) < 4:
        parts.append(0)
    return tuple(parts)


def wporg_latest_version(slug: str, timeout: int = TIMEOUT):
    # WordPress.org plugin JSON endpoint. Not available for commercial/proprietary plugins.
    url = f"https://api.wordpress.org/plugins/info/1.0/{slug}.json"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": DEF_UA}, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            if getattr(resp, "status", None) != 200:
                return None
            data = json.loads(resp.read().decode('utf-8', errors='ignore'))
            # 'version' key contains latest released version
            return data.get('version')
    except Exception:
        return None


SENSITIVE_PLUGINS = set([
    'gravityforms',
    'elementor',
    'elementor-pro',
    'woocommerce',
    'wordfence',
    'wpforms',
    'the-events-calendar',
    'event-tickets',
])


def grade_plugin_risk(slug: str, inferred_version: str | None, latest_version: str | None, exposure_hint: str | None = None):
    sensitive = slug in SENSITIVE_PLUGINS or (exposure_hint in ("forms", "ecommerce"))
    if latest_version and inferred_version and _looks_like_semver(inferred_version) and _looks_like_semver(latest_version):
        iv = _semver_key(inferred_version)
        lv = _semver_key(latest_version)
        if iv < lv:
            # Determine magnitude of lag
            if iv[0] < lv[0] or iv[1] + 2 <= lv[1]:
                return 'High'
            if iv[1] < lv[1] or iv[2] + 2 <= lv[2]:
                return 'Medium'
            return 'Low'
        else:
            return 'Low'
    # No latest available (commercial or blocked)
    if latest_version is None:
        return 'High' if sensitive else 'Medium'
    # No inferred version
    if inferred_version is None:
        return 'Medium' if sensitive else 'Low'
    return 'Medium'


def fetch_text(url: str, timeout: int = TIMEOUT, max_body: int = 400000):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": DEF_UA}, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = resp.read(max_body)
            return data.decode('utf-8', errors='ignore')
    except Exception:
        return None


def try_readme_version(base_https: str, slug: str):
    # Attempt to read /wp-content/plugins/<slug>/readme.txt and parse Stable tag or Version
    url = urljoin(base_https + '/', f'/wp-content/plugins/{slug}/readme.txt')
    txt = fetch_text(url)
    if not txt:
        return None
    # Look for Stable tag: X.Y.Z or Version: X.Y.Z
    m = re.search(r"^\s*Stable\s+tag\s*:\s*([0-9]+(?:\.[0-9]+){1,3})\s*$", txt, re.IGNORECASE | re.MULTILINE)
    if m:
        return m.group(1)
    m = re.search(r"^\s*Version\s*:\s*([0-9]+(?:\.[0-9]+){1,3})\s*$", txt, re.IGNORECASE | re.MULTILINE)
    if m:
        return m.group(1)
    return None


def build_plugin_inventory(homepage_inv: dict, pages: list[dict], base_https: str = None):
    # Collect plugin assets from homepage and sampled pages
    plugin_assets: dict[str, list[str]] = {}

    def _add(url):
        slug = extract_plugin_slug_from_url(url)
        if slug:
            plugin_assets.setdefault(slug, []).append(url)

    # Homepage
    for u in homepage_inv.get('scripts', []) + [l.get('href') for l in homepage_inv.get('links', []) if isinstance(l, dict) and l.get('href')] + homepage_inv.get('images', []):
        if u:
            _add(u)

    # Sampled pages (GET a small body and parse)
    for pg in pages:
        u = pg.get('url')
        if not u or not (pg.get('ok')):
            # Try GET to parse when HEAD was ok but no content
            pr, body = parse_homepage(u)
        else:
            pr, body = parse_homepage(u)
        if pr.get('ok'):
            inv = pr.get('inventory') or {}
            for uu in inv.get('scripts', []) + [l.get('href') for l in inv.get('links', []) if isinstance(l, dict) and l.get('href')] + inv.get('images', []):
                if uu:
                    _add(uu)

    # Build inventory list
    inventory = []
    for slug, urls in plugin_assets.items():
        inferred = infer_versions_from_urls(urls)
        # Try readme.txt version from site if available
        readme_ver = try_readme_version(base_https, slug) if base_https else None
        if readme_ver and _looks_like_semver(readme_ver):
            inferred = readme_ver
        latest = wporg_latest_version(slug)
        exposure_hint = 'forms' if slug in ('gravityforms', 'wpforms') else None
        grade = grade_plugin_risk(slug, inferred, latest, exposure_hint)
        inventory.append({
            'slug': slug,
            'inferred_version': inferred,
            'readme_version': readme_ver,
            'latest_version': latest,
            'risk_grade': grade,
            'assets_sampled': sorted(list(set(urls)))[:20],
            'notes': 'Commercial plugin — manual verification required' if latest is None and slug in ('gravityforms','elementor-pro') else None,
        })
    # Sort by risk then slug
    risk_order = {'High': 0, 'Medium': 1, 'Low': 2}
    inventory.sort(key=lambda x: (risk_order.get(x['risk_grade'], 3), x['slug']))
    return inventory


def write_plugins_report(path_md: str, inventory: list[dict]):
    lines = []
    lines.append("Plugins Risk Report (Plain English)")
    lines.append("")
    if not inventory:
        lines.append("No WordPress plugins were detected from public assets on sampled pages.")
    else:
        high = [p for p in inventory if p['risk_grade']=='High']
        med = [p for p in inventory if p['risk_grade']=='Medium']
        low = [p for p in inventory if p['risk_grade']=='Low']
        lines.append(f"Detected {len(inventory)} plugins in public assets — High: {len(high)}, Medium: {len(med)}, Low: {len(low)}.")
        lines.append("")
        for p in inventory:
            lines.append(f"- {p['slug']}: Risk {p['risk_grade']} — Inferred version: {p.get('inferred_version') or 'unknown'}; Latest: {p.get('latest_version') or 'manual check'}")
            if p.get('notes'):
                lines.append(f"  Note: {p['notes']}")
            lines.append("  Examples of misuse if not up-to-date:")
            if p['slug'] in ('gravityforms','wpforms'):
                lines.append("  - Form plugins have had bugs that allowed attackers to read or inject content; outdated forms could expose donor inputs.")
            elif p['slug'].startswith('elementor'):
                lines.append("  - Page builders process lots of content; past bugs enabled unauthorized access or script injection, risking content defacement or data leakage.")
            elif p['slug'] in ('the-events-calendar','event-tickets'):
                lines.append("  - Event plugins add custom endpoints; past issues have enabled content changes or data exposure if unpatched.")
            else:
                lines.append("  - Outdated plugins are a common entry point for site compromise or data exposure.")
            lines.append("  Suggested next step: Verify the installed version in WordPress Admin and update to the latest stable release; enable auto-updates where sensible.")
            lines.append("")
    with open(path_md, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines) + "\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--domain", default="www.myunitedway.ca")
    ap.add_argument("--out", default="artifacts/webscan")
    ap.add_argument("--traverse", type=int, default=10)
    args = ap.parse_args()

    ensure_dir(args.out)

    domain = args.domain.strip()
    http_url = f"http://{domain}"
    https_url = f"https://{domain}"

    resolved_ips = resolve_all(domain)
    http_head = fetch(http_url, method="HEAD")
    https_head = fetch(https_url, method="HEAD")
    if not https_head.get("ok"):
        https_head = fetch(https_url, method="GET", max_body=4096)

    tls = get_tls_info(domain, 443)
    sec = check_security_headers(https_head.get("headers", {}))

    robots = fetch(f"{https_url}/robots.txt", method="GET", max_body=200000)
    sitemap = fetch(f"{https_url}/sitemap.xml", method="GET", max_body=400000)

    # Deep checks
    homepage_details, body = parse_homepage(https_url)
    details_dir = os.path.join(args.out, 'details')
    ensure_dir(details_dir)
    if homepage_details.get("ok") and body:
        try:
            with open(os.path.join(details_dir, 'homepage.html'), 'wb') as hf:
                hf.write(body)
        except Exception:
            pass

    set_cookies = []
    hdrs = homepage_details.get('headers') or https_head.get('headers') or {}
    # Combine any Set-Cookie values found
    for k, v in hdrs.items():
        if k.lower() == 'set-cookie':
            # Can be merged; split approximate by comma only if it separates cookies
            # Simpler: treat whole header as one cookie if multiple present
            set_cookies.append(v)
    cookie_analysis = parse_cookies(set_cookies) if set_cookies else []

    apex_https = f"https://{args.domain.split('.', 1)[-1]}" if args.domain.startswith('www.') else f"https://{args.domain}"
    endpoints = check_known_endpoints(https_url, apex_https)

    # Sitemap traversal
    pages = []
    if sitemap.get('ok') and sitemap.get('status') == 200:
        urls = parse_sitemap(f"{https_url}/sitemap.xml", limit=max(1, min(args.traverse, 10)))
        for u in urls:
            pr = fetch(u, method="HEAD")
            if not pr.get('ok'):
                pr = fetch(u, method="GET", max_body=2048)
            pages.append({"url": u, "status": pr.get('status'), "ok": pr.get('ok'), "headers": pr.get('headers')})

    headers_txt = os.path.join(args.out, "headers.txt")
    try:
        with open(headers_txt, "w", encoding="utf-8") as f:
            if https_head.get("headers"):
                for k, v in https_head["headers"].items():
                    f.write(f"{k}: {v}\n")
    except Exception:
        pass

    if robots.get("ok") and robots.get("body_sample_sha256") is None:
        try:
            with urllib.request.urlopen(
                urllib.request.Request(f"{https_url}/robots.txt", headers={"User-Agent": DEF_UA})
            ) as r:
                with open(os.path.join(args.out, "robots.txt"), "wb") as rf:
                    rf.write(r.read())
        except Exception:
            pass
    if sitemap.get("ok") and sitemap.get("body_sample_sha256") is None:
        try:
            with urllib.request.urlopen(
                urllib.request.Request(f"{https_url}/sitemap.xml", headers={"User-Agent": DEF_UA})
            ) as r:
                with open(os.path.join(args.out, "sitemap.xml"), "wb") as sf:
                    sf.write(r.read())
        except Exception:
            pass

    results = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "domain": domain,
        "resolved_ips": resolved_ips,
        "http": {
            "url": http_url,
            "status": http_head.get("status"),
            "final_url": http_head.get("final_url"),
            "redirects_to_https": (http_head.get("final_url") or "").startswith("https://"),
            "ok": http_head.get("ok", False),
            "error": http_head.get("error"),
        },
        "https": {
            "url": https_url,
            "status": https_head.get("status"),
            "final_url": https_head.get("final_url"),
            "ok": https_head.get("ok", False),
            "error": https_head.get("error"),
        },
        "tls": tls,
        "security_headers": sec,
        "extra_headers": {
            "server": hdrs.get('server'),
            "x_powered_by": hdrs.get('x-powered-by'),
            "cf_ray": hdrs.get('cf-ray'),
            "csp": hdrs.get('content-security-policy'),
            "csp_report_only": hdrs.get('content-security-policy-report-only'),
        },
        "artifacts": {
            "headers_txt": os.path.relpath(headers_txt, start=os.getcwd()),
            "robots": "robots.txt" if robots.get("ok") else None,
            "sitemap": "sitemap.xml" if sitemap.get("ok") else None,
        },
        "homepage": {
            "ok": homepage_details.get('ok'),
            "status": homepage_details.get('status'),
            "final_url": homepage_details.get('final_url'),
            "sha256": homepage_details.get('sha256'),
            "size": homepage_details.get('size'),
            "inventory": homepage_details.get('inventory'),
            "third_party_origins": homepage_details.get('third_party_origins'),
            "has_mixed_content_refs": homepage_details.get('has_mixed_content_refs'),
        },
        "cookies": cookie_analysis,
        "known_endpoints": endpoints,
        "sitemap_sample": pages,
    }

    # Build plugin inventory and write reports
    plugins_inventory = []
    try:
        plugins_inventory = build_plugin_inventory(homepage_details.get('inventory', {}) if homepage_details else {}, pages)
    except Exception as e:
        plugins_inventory = [{"error": f"inventory_failed: {e}"}]
    results["plugins"] = plugins_inventory

    plugins_json_path = os.path.join(args.out, "plugins.json")
    with open(plugins_json_path, 'w', encoding='utf-8') as pf:
        json.dump(plugins_inventory, pf, indent=2, ensure_ascii=False)

    plugins_report_path = os.path.join(args.out, "plugins_report.md")
    try:
        write_plugins_report(plugins_report_path, plugins_inventory)
    except Exception:
        pass

    with open(os.path.join(args.out, "results.json"), "w", encoding="utf-8") as jf:
        json.dump(results, jf, indent=2, ensure_ascii=False)

    summary = []
    summary.append(f"# Web Scan Summary — {domain}")
    summary.append(f"- Timestamp: {results['timestamp']}")
    summary.append(
        f"- Resolved IPs: {', '.join(results['resolved_ips']) if results['resolved_ips'] else 'n/a'}"
    )
    summary.append(
        f"- HTTP status: {results['http']['status']} → {results['http']['final_url']}"
    )
    summary.append(
        f"- HTTPS status: {results['https']['status']} → {results['https']['final_url']}"
    )
    if tls.get("ok"):
        summary.append(
            f"- TLS expiry (days): {tls.get('days_until_expiry')}, notAfter: {tls.get('not_after')}"
        )
    else:
        summary.append(f"- TLS error: {tls.get('error')}")
    summary.append(
        f"- Security headers grade: {sec.get('grade')} — missing: {', '.join(sec.get('missing', []))}"
    )
    summary.append(f"- Artifacts: results.json, headers.txt, robots.txt, sitemap.xml")
    with open(os.path.join(args.out, "summary.md"), "w", encoding="utf-8") as sf:
        sf.write("\n".join(summary) + "\n")


if __name__ == "__main__":
    main()
