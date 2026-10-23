#!/usr/bin/env bash
# Stop hook: before Claude says "done", run the fast gate in every AI worktree that has uncommitted changes.
# Exit 2 blocks the stop and shows the failure to Claude. One retry only, to avoid loops.
input=$(cat)
active=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active", False))' 2>/dev/null)
[ "$active" = "True" ] && exit 0
kit="$(bash "$(dirname "$0")/kit-resolve.sh" "${CLAUDE_PROJECT_DIR:-$PWD}")" || exit 0
AI_MODE=worktree; [ -f "$kit/.ai/mode.conf" ] && . "$kit/.ai/mode.conf"
root="$(dirname "$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")"
fail=""
places=("$kit"/worktrees/*/); [ "$AI_MODE" = direct ] && places+=("$root/")
for wt in "${places[@]}"; do
  [ -d "$wt" ] || continue
  [ -e "$wt/.git" ] || continue
  [ -n "$(git -C "$wt" status --porcelain)" ] || continue
  out=$(cd "$wt" && bash "$kit/.ai/verify.sh" --fast 2>&1) || fail="$fail
== $wt
$(printf '%s' "$out" | tail -30)"
done
[ -z "$fail" ] && exit 0
printf 'Fast gate failed. Fix this (or commit and say it is red) before finishing:%s\n' "$fail" >&2
exit 2
