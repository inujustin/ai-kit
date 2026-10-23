#!/usr/bin/env bash
# PreToolUse(Bash): Claude may commit only on ai/* branches, and may never push an ai/* branch or force-push.
# Pushing your own branch stays allowed, but settings.local.json makes it ask you every time.
# Exit 2 blocks the command and tells Claude why. Merges into your branch go through .ai/bin/mergesession.
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
cwd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)
printf '%s' "$cmd" | grep -qE '(^|[^[:alnum:]_-])git([[:space:]]|$)' || exit 0
# Only in repos that have a registered kit (other repos follow their own rules).
bash "$(dirname "$0")/kit-resolve.sh" "${cwd:-$PWD}" >/dev/null || exit 0

block() { echo "Blocked by ai-kit guard-git: $1" >&2; exit 2; }

if printf '%s' "$cmd" | grep -qE 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push'; then
  printf '%s' "$cmd" | grep -qE '(--force|[[:space:]]-f([[:space:]]|$)|--force-with-lease|\+[^[:space:]]+)' && block "no force-push."
  printf '%s' "$cmd" | grep -qE '[[:space:]]ai/' && block "ai/* branches stay local."
  printf '%s' "$cmd" | grep -qE '[[:space:]](--all|--mirror)' && block "push one named branch only."
  printf '%s' "$cmd" | grep -qE '[[:space:]:](main|master|develop)([[:space:]]|$)' && block "never push straight to main/master/develop; push your branch and open a PR."
fi

# Kit files never go into a project repo: block a commit whose staged files look like kit files.
if printf '%s' "$cmd" | grep -qE 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)'; then
  kdir=$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+("?)([^"[:space:]]+)\1.*/\2/p'); kdir="${kdir:-$cwd}"
  leak=$(git -C "$kdir" diff --cached --name-only 2>/dev/null | grep -E '^(\.ai/|CLAUDE\.local\.md$|worktrees/|\.claude/plans/)|(^|/)tickets/T[0-9]+[^/]*\.md$' | head -5)
  [ -n "$leak" ] && block "these staged files look like ai-kit, ticket or plan files, which never enter the repo: $leak. Unstage them (git restore --staged <file>)."
fi

if printf '%s' "$cmd" | grep -qE 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+(commit|cherry-pick|revert)([[:space:]]|$)'; then
  dir=$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+("?)([^"[:space:]]+)\1.*/\2/p')
  [ -z "$dir" ] && dir=$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+("?)([^"[:space:]&;]+)\1.*/\2/p')
  [ -z "$dir" ] && dir="$cwd"
  case "$dir" in /*) ;; *) dir="$cwd/$dir" ;; esac
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  case "$branch" in ai/*) ;; *) block "commit only on ai/* branches (this is '$branch'). Use \$KIT/.ai/bin/newsession, then \$KIT/.ai/bin/story when the user asks." ;; esac
fi
exit 0
