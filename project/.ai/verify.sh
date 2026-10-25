#!/usr/bin/env bash
# The gate. Claude, Codex and the hooks all run this same script.
#   bash $KIT/.ai/verify.sh          full gate (before merge / PR / gate); run from the repo
#   bash $KIT/.ai/verify.sh --fast   checks that finish in seconds
set -uo pipefail
# shellcheck source=/dev/null
. "$(dirname "$0")/lib.sh"
#   bash $KIT/.ai/verify.sh --all    check every tracked file, not only the changed ones (onboarding audit)
# Runs in place (no copy of the project). If a check rewrites files (a pre-commit hook, a formatter), it says which,
# so the AI can tell the user instead of committing changes nobody asked for.
top="$(git rev-parse --show-toplevel)"
cd "$top"
before="$(git status --porcelain)"

# Files changed on this branch since its base (lib.sh kit_base), plus uncommitted and untracked ones.
from="$(git merge-base HEAD "$(kit_base)" 2>/dev/null || echo HEAD)"
CHANGED="$( { git diff --name-only --diff-filter=ACMR "$from"; git ls-files --others --exclude-standard; } | sort -u)"
[ "${1:-}" = "--all" ] || [ "${2:-}" = "--all" ] && CHANGED="$(git ls-files)"
export CHANGED

FAST=()
FULL=()
# shellcheck source=/dev/null
. "$KIT/.ai/verify.conf"

mode=full
for arg in "$@"; do [ "$arg" = "--fast" ] && mode=fast; done
fail=0
run() { printf '\n> %s\n' "$1"; bash -c "$1" || { printf 'FAILED: %s\n' "$1"; fail=1; }; }

for c in "${FAST[@]}"; do run "$c"; done
if [ "$mode" = full ]; then
  [ ${#FULL[@]} -eq 0 ] && { echo "FULL is empty: fill $KIT/.ai/verify.conf"; fail=1; }
  for c in "${FULL[@]}"; do run "$c"; done
fi

after="$(git status --porcelain)"
[ "$before" = "$after" ] || { echo; echo "NOTE: the checks changed files in the working tree (tell the user; do not commit them silently):"; diff <(echo "$before") <(echo "$after") | sed -n 's/^> /  /p'; }
if [ $fail -eq 0 ]; then echo "verify ($mode): PASS"; else echo "verify ($mode): FAIL"; fi
exit $fail
