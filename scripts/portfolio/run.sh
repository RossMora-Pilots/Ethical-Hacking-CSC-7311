#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
# Prefer JSON config; fall back to YAML for backward-compat
if [[ -f "$ROOT/portfolio/config.json" ]]; then
  CONFIG="$ROOT/portfolio/config.json"
elif [[ -f "$ROOT/portfolio/config.yaml" ]]; then
  CONFIG="$ROOT/portfolio/config.yaml"
else
  CONFIG="$ROOT/portfolio/config.json"
fi

phase="${1:-}"
if [[ -z "${phase}" ]]; then
  echo "Usage: $0 <immediate|short|followup|polish|enhance|all>" >&2
  exit 2
fi

python_bin="python3"
if ! command -v "$python_bin" >/dev/null 2>&1; then
  echo "python3 not found in PATH" >&2
  exit 2
fi

run_immediate() {
  "$python_bin" "$ROOT/scripts/portfolio/update_main_readme.py" --root "$ROOT" --config "$CONFIG"
  "$python_bin" "$ROOT/scripts/portfolio/index_assignments.py" --root "$ROOT" --config "$CONFIG"
}

run_short() {
  "$python_bin" "$ROOT/scripts/portfolio/create_midterm_summary.py" --root "$ROOT" --config "$CONFIG"
  "$python_bin" "$ROOT/scripts/portfolio/create_final_assessment.py" --root "$ROOT" --config "$CONFIG"
}

run_followup() {
  "$python_bin" "$ROOT/scripts/portfolio/build_evidence_index.py" --root "$ROOT" --config "$CONFIG"
  "$python_bin" "$ROOT/scripts/portfolio/build_scripts_readme.py" --root "$ROOT" --config "$CONFIG"
}

run_polish() {
  "$python_bin" "$ROOT/scripts/portfolio/create_weeks_summary.py" --root "$ROOT" --config "$CONFIG" || true
  "$python_bin" "$ROOT/scripts/portfolio/add_references.py" --root "$ROOT" --config "$CONFIG" || true
  "$python_bin" "$ROOT/scripts/portfolio/build_evidence_index.py" --root "$ROOT" --config "$CONFIG" || true
  "$python_bin" "$ROOT/scripts/portfolio/build_scripts_readme.py" --root "$ROOT" --config "$CONFIG" || true
  wf="$ROOT/.github/workflows/portfolio-ci.yml"
  mkdir -p "$(dirname "$wf")"
  if [[ ! -f "$wf" ]]; then
    cat > "$wf" <<'YML'
name: Portfolio CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
jobs:
  link-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Link Checker
        uses: lycheeverse/lychee-action@v1
        with:
          args: --no-progress --exclude-mail --accept 200,206 --verbose '**/*.md'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: |
            CC
            scripts
YML
  fi
}

run_enhance() {
  "$python_bin" "$ROOT/scripts/portfolio/add_architecture_diagrams.py" --root "$ROOT" --config "$CONFIG" || true
  "$python_bin" "$ROOT/scripts/portfolio/add_learning_reflection.py" --root "$ROOT" --config "$CONFIG" || true
  "$python_bin" "$ROOT/scripts/portfolio/add_root_highlights.py" --root "$ROOT" || true
  "$python_bin" "$ROOT/scripts/portfolio/build_evidence_index.py" --root "$ROOT" --config "$CONFIG" || true
}

case "$phase" in
  immediate) run_immediate ;;
  short) run_short ;;
  followup) run_followup ;;
  polish) run_polish ;;
  enhance) run_enhance ;;
  all)
    run_immediate
    run_short
    run_followup
    run_polish || true
    run_enhance || true
    ;;
  *) echo "Unknown phase: $phase" >&2; exit 2 ;;
esac

if [[ "${PM_COMMIT:-1}" != "0" ]]; then
  cd "$ROOT"
  if ! git diff --quiet; then
    git add -A
    case "$phase" in
      immediate)
        subject="docs(root): add Quick Start/Achievements/Navigation/Skills; regenerate assignments index"
        body="Why: Improve recruiter-first scan and navigability.\nPhase: immediate";;
      short)
        subject="docs(course): add Midterm + Final writeups with metrics and evidence links"
        body="Why: Surface quantified results and capstone depth.\nPhase: short";;
      followup)
        subject="docs(course): add Evidence Index + Scripts README with usage; validate scripts"
        body="Why: Provide context for evidence and executable scripts.\nPhase: followup";;
      polish)
        subject="docs(course,ci): add Weeks summary + References; add CI; rebuild evidence/scripts docs"
        body="Why: Improve completeness and automated validation.\nPhase: polish";;
      enhance)
        subject="docs(root,course): add architecture diagrams + learning reflection + highlights; expand captions"
        body="Why: Add narrative depth and faster entry points.\nPhase: enhance";;
      *)
        subject="docs(portfolio): update generated artifacts"; body="Phase: $phase";;
    esac
    changed=$(git diff --cached --name-only | sed -n '1,50p')
    git -c user.email="codex-bot@local" -c user.name="Codex Bot" commit -m "$subject" -m "$body" -m "Files:\n$changed" || true
    if [[ "${PM_PUSH:-0}" == "1" ]]; then
      git push origin "${PORTFOLIO_BRANCH:-main}" || true
    fi
  fi
fi

echo "Phase '$phase' completed."
