#!/usr/bin/env python3
"""Extract embedded images from DOCX submissions into screenshots/ folder.

DOCX files are ZIP archives; images live under word/media/.
This script extracts them, converts to PNG where needed, and renames
per the portfolio naming convention: wkNN_topic_index.png
"""

import os
import re
import sys
import zipfile
from pathlib import Path
from PIL import Image
import io
import struct

# ── Configuration ──────────────────────────────────────────────────────
ONEDRIVE_BASE = Path(
    r"C:\Users\rossm\OneDrive - HLRMDR\OneDrive - Ross - HLRMDR - Folder"
    r"\CC\CC\January 2025\Ethical Hacking - Jeff Caldwell - CSC7311 - 11825"
)

REPO_ROOT = Path(r"D:\pilots\409-Ethical-Hacking")
SCREENSHOTS_DIR = REPO_ROOT / "CC" / "Winter 2025" / \
    "Ethical Hacking - Jeff Caldwell - CSC-7311-11825" / "screenshots"

# Student submissions mapped to week/topic slugs
STUDENT_DOCX = {
    "Week 3/A00322717 Ross Moravec Cyber Kill Chain (Part 1 and Part 2).docx": "wk03_cyber_kill_chain",
    "Week 4/Lab 3/A00322717 Ross Moravec - Module 03 - Further Nmap.docx": "wk04_further_nmap",
    "Week 4/Lab 3/A00322717 Ross Moravec - Module 03 - OSI & Recon - Intro to Web App Security.docx": "wk04_osi_recon_webapp",
    "Week 5/A00322717 Ross Moravec Enumeration Brute Force OpenVAS Scanner.docx": "wk05_enum_bruteforce_openvas",
    "Week 6/A00322717 Ross Moravec Network Services (Part 1-2-3).docx": "wk06_network_services",
    "Week 8/A00322717 Ross Moravec Midterm Pickle Rick.docx": "wk08_pickle_rick",
    "Week 10/A00322717 Ross Moravec Phishing Analysis [PART 1] and Phishing in Action [PART 2].docx": "wk10_phishing",
    "Week 11/A00322717 Ross Moravec - Live Host Scanning - Nmap Live Host Discovery.docx": "wk11_nmap_live_host",
    "Week 11/A00322717 Ross Moravec Wireless Hacking 101 on 2025-03-24.docx": "wk11_wireless_hacking",
    "Week 12/A00322717 Ross Moravec Lab Mr Robot CTF Wordpress.docx": "wk12_mr_robot",
    "Week 13/A00322717 Ross Moravec - Final Exam - Boiler CTF.docx": "wk13_boiler_ctf",
    "Week 13/A00322717 Ross Moravec ETH Final Exam.docx": "wk13_eth_final_exam",
    "Week 13/A00322717 Ross Moravec OWASP Top 10.docx": "wk13_owasp_top10",
}

# Minimum image dimensions to skip tiny decorative images / bullets
MIN_WIDTH = 80
MIN_HEIGHT = 80

# Image extensions we care about
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff", ".tif"}

# EMF/WMF are Windows metafiles — we'll skip those as they're usually logos
SKIP_EXTENSIONS = {".emf", ".wmf"}


def is_valid_screenshot(img_data: bytes, filename: str) -> bool:
    """Check if an image is large enough to be a real screenshot."""
    ext = Path(filename).suffix.lower()
    if ext in SKIP_EXTENSIONS:
        return False
    if ext not in IMAGE_EXTENSIONS:
        return False
    try:
        img = Image.open(io.BytesIO(img_data))
        w, h = img.size
        return w >= MIN_WIDTH and h >= MIN_HEIGHT
    except Exception:
        return False


def convert_to_png(img_data: bytes, filename: str) -> bytes:
    """Convert any image format to PNG for consistency."""
    ext = Path(filename).suffix.lower()
    if ext == ".png":
        return img_data
    try:
        img = Image.open(io.BytesIO(img_data))
        if img.mode in ("RGBA", "P"):
            img = img.convert("RGBA")
        else:
            img = img.convert("RGB")
        buf = io.BytesIO()
        img.save(buf, format="PNG", optimize=True)
        return buf.getvalue()
    except Exception as e:
        print(f"  ⚠ Could not convert {filename}: {e}")
        return img_data


def extract_images_from_docx(docx_path: Path, topic_slug: str, output_dir: Path) -> list:
    """Extract all meaningful images from a DOCX file."""
    extracted = []
    if not docx_path.exists():
        print(f"  ✗ File not found: {docx_path}")
        return extracted

    try:
        with zipfile.ZipFile(docx_path, 'r') as zf:
            media_files = sorted([
                n for n in zf.namelist()
                if n.startswith("word/media/")
            ])

            idx = 0
            for media_file in media_files:
                img_data = zf.read(media_file)
                orig_name = Path(media_file).name

                if not is_valid_screenshot(img_data, orig_name):
                    continue

                idx += 1
                png_data = convert_to_png(img_data, orig_name)
                out_name = f"{topic_slug}_{idx:02d}.png"
                out_path = output_dir / out_name

                out_path.write_bytes(png_data)
                extracted.append(out_name)

    except zipfile.BadZipFile:
        print(f"  ✗ Bad ZIP/DOCX: {docx_path}")
    except Exception as e:
        print(f"  ✗ Error processing {docx_path}: {e}")

    return extracted


def main():
    print(f"Screenshot Extraction Tool")
    print(f"{'='*60}")
    print(f"Source: {ONEDRIVE_BASE}")
    print(f"Target: {SCREENSHOTS_DIR}")
    print()

    SCREENSHOTS_DIR.mkdir(parents=True, exist_ok=True)

    total_extracted = 0
    manifest = {}  # topic_slug -> list of filenames

    for rel_path, topic_slug in sorted(STUDENT_DOCX.items()):
        docx_path = ONEDRIVE_BASE / rel_path
        week = topic_slug.split("_")[0]
        print(f"[{week}] {topic_slug}")
        print(f"  Source: ...{rel_path[-60:]}")

        images = extract_images_from_docx(docx_path, topic_slug, SCREENSHOTS_DIR)

        if images:
            print(f"  ✓ Extracted {len(images)} screenshots")
            manifest[topic_slug] = images
            total_extracted += len(images)
        else:
            print(f"  ○ No qualifying screenshots found")

    print()
    print(f"{'='*60}")
    print(f"Total: {total_extracted} screenshots extracted to screenshots/")
    print()

    # Summary by week
    print("Summary by topic:")
    for slug in sorted(manifest.keys()):
        print(f"  {slug}: {len(manifest[slug])} images")

    return manifest


if __name__ == "__main__":
    manifest = main()
