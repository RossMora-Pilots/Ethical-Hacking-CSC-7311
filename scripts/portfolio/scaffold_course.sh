#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 "<Term>" "<Course Name - Instructor - Code>"

Example:
  $0 "September 2024" "Network Defense - Travis Czech - CSC-7303-002 - 93536"

Creates:
  CC/<Term>/<Course>/
    assignments/ (empty)
    scripts/ (empty)
    scripts-extra/ (empty)
    screenshots/ (empty)
    README.md (placeholder)
    MIDTERM_PROJECT_SUMMARY.md (stub)
    FINAL_EXAM_VULNERABILITY_ASSESSMENT.md (stub)
    EVIDENCE_INDEX.md (stub)
    SCRIPTS_README.md (stub)
USAGE
}

if [[ $# -ne 2 ]]; then
  usage >&2
  exit 2
fi

TERM="$1"
COURSE="$2"

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
BASE="${ROOT_DIR}/CC/${TERM}/${COURSE}"

mkdir -p "${BASE}/assignments" "${BASE}/scripts" "${BASE}/scripts-extra" "${BASE}/screenshots"

write_if_missing() {
  local path="$1"; shift
  if [[ ! -f "$path" ]]; then
    printf "%s\n" "$*" > "$path"
  fi
}

write_if_missing "${BASE}/README.md" "# ${COURSE}

> Start Here: course overview, goals, and navigation.

## Quick Links

- Midterm Project Summary → MIDTERM_PROJECT_SUMMARY.md
- Final Exam Vulnerability Assessment → FINAL_EXAM_VULNERABILITY_ASSESSMENT.md
- Evidence & Screenshots → EVIDENCE_INDEX.md
- Scripts Overview → SCRIPTS_README.md

## Naming Conventions

- Folder: CC/<Term>/<Course Name - Instructor - Code>
- Screenshots: wkNN_topic_index.png (e.g., wk01_labsetup_1.png) or ScreenshotN_ShortDesc.png
- Scripts: student-authored in scripts/; external/reference in scripts-extra/
"

write_if_missing "${BASE}/MIDTERM_PROJECT_SUMMARY.md" "# Midterm Project Summary

TBD — add architecture, metrics, evidence links.
"

write_if_missing "${BASE}/FINAL_EXAM_VULNERABILITY_ASSESSMENT.md" "# Final Exam: Vulnerability Assessment

TBD — add process, metrics, and validation results.
"

write_if_missing "${BASE}/EVIDENCE_INDEX.md" "# Evidence & Screenshots Index

TBD — group screenshots by topic/week with captions.
"

write_if_missing "${BASE}/SCRIPTS_README.md" "# Scripts Overview

TBD — list scripts with usage and validation steps.
"

echo "Scaffolded: ${BASE}" >&2
