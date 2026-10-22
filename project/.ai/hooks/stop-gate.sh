#!/usr/bin/env bash
# Stop hook: before Claude says "done", run the fast gate in every AI worktree that has uncommitted changes.
# Exit 2 blocks the stop and shows the failure to Claude. One retry only, to avoid loops.
input=$(cat)
active=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active", False))' 2>/dev/null)
[ "$active" = "True" ] && exit 0
root="${CLAUDE_PROJECT_DIR:-.}"
[ -d "$root/.worktrees" ] || exit 0
fail=""
for wt in "$root"/.worktrees/*/; do
  [ -e "$wt/.git" ] || continue
  [ -n "$(git -C "$wt" status --porcelain)" ] || continue
  out=$(cd "$wt" && bash .ai/verify.sh --fast 2>&1) || fail="$fail
== $wt
$(printf '%s' "$out" | tail -30)"
done
[ -z "$fail" ] && exit 0
printf 'Fast gate failed. Fix this (or commit and say it is red) before finishing:%s\n' "$fail" >&2
exit 2
