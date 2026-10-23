#!/usr/bin/env bash
# The gate. Claude, Codex and the hooks all run this same script.
#   bash $KIT/.ai/verify.sh          full gate (before merge / PR / gate); run from the repo or a worktree
#   bash $KIT/.ai/verify.sh --fast   checks that finish in seconds
set -uo pipefail
# shellcheck source=/dev/null
. "$(dirname "$0")/lib.sh"
#   bash $KIT/.ai/verify.sh --all    check every tracked file, not only the changed ones (onboarding audit)
# Never changes the team's checkout: run from the repo's main folder, it re-runs itself in a throw-away worktree of HEAD
# inside the kit, so fixers inside the checks (pre-commit hooks, formatters) can only touch that copy.
top="$(git rev-parse --show-toplevel)"
if [ "$top" = "$ROOT" ] && [ -z "${AI_VERIFY_NESTED:-}" ]; then
  tmp="$WT_DIR/.verify-$$"; mkdir -p "$WT_DIR"
  git -C "$ROOT" worktree add -q --detach "$tmp" HEAD
  echo "(verify runs on a throw-away copy of HEAD in $tmp; your checkout is never modified; uncommitted changes are not included)"
  (cd "$tmp" && AI_VERIFY_NESTED=1 bash "$KIT/.ai/verify.sh" "$@"); rc=$?
  git -C "$ROOT" worktree remove --force "$tmp"; exit $rc
fi
cd "$top"

# Files changed on this branch since its base (set by newsession), plus uncommitted and untracked ones.
branch="$(git branch --show-current)"
base="$(git config "branch.$branch.aibase" || true)"
from="HEAD"
[ -n "$base" ] && from="$(git merge-base HEAD "$base")"
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

if [ $fail -eq 0 ]; then echo "verify ($mode): PASS"; else echo "verify ($mode): FAIL"; fi
exit $fail
