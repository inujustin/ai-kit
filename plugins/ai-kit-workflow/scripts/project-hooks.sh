#!/usr/bin/env bash
# Run this project's own hooks: every *.sh in $KIT/.ai/hooks/<Event>/ (same stdin JSON, same exit-code rules as Claude
# Code hooks: exit 2 blocks with stderr shown to Claude). Lets a project add hooks inside its own kit, without
# touching the shared ai-kit source or the plugin. Usage (from hooks.json): project-hooks.sh <Event>
event="${1:?event}"
input=$(cat)
cwd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)
kit="$(bash "$(dirname "$0")/kit-resolve.sh" "${cwd:-$PWD}")" || exit 0
dir="$kit/.ai/hooks/$event"
[ -d "$dir" ] || exit 0
rc=0
for h in "$dir"/*.sh; do
  [ -f "$h" ] || continue
  printf '%s' "$input" | KIT="$kit" bash "$h"; r=$?
  [ $r -eq 2 ] && rc=2
done
exit $rc
