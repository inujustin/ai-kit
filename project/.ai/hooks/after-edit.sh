#!/usr/bin/env bash
# PostToolUse(Edit|Write): run the team's pre-commit hooks (ruff, eslint, prettier...) on the file Claude just touched.
# Exit 2 sends the lint output back to Claude so it fixes the problem now. Skipped if pre-commit is not installed.
file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
[ -f "$file" ] || exit 0
command -v pre-commit >/dev/null || exit 0
dir="$(cd "$(dirname "$file")" && git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[ -f "$dir/.pre-commit-config.yaml" ] || exit 0
cd "$dir" || exit 0
rel="${file#"$dir"/}"
# First run may only reformat the file (exit 1). A second failing run is a real problem.
pre-commit run -q --files "$rel" >/dev/null 2>&1 && exit 0
out=$(pre-commit run --files "$rel" 2>&1) && exit 0
printf 'pre-commit failed on %s:\n%s\n' "$rel" "$(printf '%s' "$out" | tail -30)" >&2
exit 2
