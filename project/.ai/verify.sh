#!/usr/bin/env bash
# The gate. Claude, Codex and the hooks all run this same script.
#   bash .ai/verify.sh          full gate (before merge / PR / gate)
#   bash .ai/verify.sh --fast   checks that finish in seconds
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

# Files changed on this branch since its base (set by newsession), plus uncommitted and untracked ones.
branch="$(git branch --show-current)"
base="$(git config "branch.$branch.aibase" || true)"
from="HEAD"
[ -n "$base" ] && from="$(git merge-base HEAD "$base")"
CHANGED="$( { git diff --name-only --diff-filter=ACMR "$from"; git ls-files --others --exclude-standard; } | sort -u)"
export CHANGED

FAST=()
FULL=()
# shellcheck source=/dev/null
. .ai/verify.conf

mode=full
[ "${1:-}" = "--fast" ] && mode=fast
fail=0
run() { printf '\n> %s\n' "$1"; bash -c "$1" || { printf 'FAILED: %s\n' "$1"; fail=1; }; }

for c in "${FAST[@]}"; do run "$c"; done
if [ "$mode" = full ]; then
  [ ${#FULL[@]} -eq 0 ] && { echo "FULL is empty: fill .ai/verify.conf"; fail=1; }
  for c in "${FULL[@]}"; do run "$c"; done
fi

if [ $fail -eq 0 ]; then echo "verify ($mode): PASS"; else echo "verify ($mode): FAIL"; fi
exit $fail
