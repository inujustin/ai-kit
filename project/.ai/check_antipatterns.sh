#!/usr/bin/env bash
# Rule-coded grep checks on the files in $CHANGED (set by verify.sh), so old code does not block new work.
# `bash .ai/check_antipatterns.sh --all` checks the whole repo instead (for a one-time audit).
# A line that contains "<CODE>:" (e.g. "# R-A1: batch job, one commit per 100 rows") is an accepted exception.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"
if [ "${1:-}" = "--all" ]; then
  files="$(git ls-files)"
else
  files="${CHANGED-$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u)}"
fi
bad=0

# rule CODE "file globs" "path ERE where it applies" "exempt ERE (path or text)" "pattern ERE" "message"
rule() {
  local code=$1 globs=$2 where=$3 exempt=$4 pattern=$5 msg=$6 g list hits
  list="$(printf '%s\n' "$files" | while read -r f; do
    [ -f "$f" ] || continue
    IFS=',' read -ra gs <<< "$globs"
    for g in "${gs[@]}"; do case "$(basename "$f")" in $g) echo "$f"; break ;; esac; done
  done | grep -E -- "$where" | grep -vE '(^|/)(node_modules|dist|build|public/frontend)/')"
  [ -n "$list" ] || return 0
  hits=$(printf '%s\n' "$list" | xargs -d '\n' grep -nHE -e "$pattern" 2>/dev/null | grep -v -- "$code:")
  if [ -n "$exempt" ] && [ -n "$hits" ]; then hits=$(printf '%s\n' "$hits" | grep -vE -- "$exempt"); fi
  if [ -n "$hits" ]; then printf '\n%s  %s\n%s\n' "$code" "$msg" "$hits"; bad=1; fi
  return 0
}

# shellcheck source=/dev/null
. .ai/antipatterns.rules.sh
[ $bad -eq 0 ] && echo "antipatterns: PASS"
exit $bad
