#!/usr/bin/env bash
# Stop hook: before Claude says "done", run the fast gate in the repo when it has uncommitted changes.
# Exit 2 blocks the stop and shows the failure to Claude. One retry only, to avoid loops.
input=$(cat)
active=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active", False))' 2>/dev/null)
[ "$active" = "True" ] && exit 0
kit="$(bash "$(dirname "$0")/kit-resolve.sh" "${CLAUDE_PROJECT_DIR:-$PWD}")" || exit 0
root="$(dirname "$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")"
fail=""
if [ -n "$(git -C "$root" status --porcelain 2>/dev/null)" ]; then
  out=$(cd "$root" && bash "$kit/.ai/verify.sh" --fast 2>&1) || fail="
$(printf '%s' "$out" | tail -30)"
fi
[ -z "$fail" ] && exit 0
printf 'Fast gate failed. Fix this (or commit and say it is red) before finishing:%s\n' "$fail" >&2
exit 2
