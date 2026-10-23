#!/usr/bin/env bash
# Print the kit folder registered for the repo that contains directory $1 (default: current directory).
# Registry: ${XDG_CONFIG_HOME:-~/.config}/ai-kit/projects.tsv, one line per project: <repo main folder><TAB><kit folder>.
# Works from the repo's main folder and from any of its worktrees (also the ones inside the kit). Exit 1 if none.
dir="${1:-$PWD}"
common="$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || exit 1
root="$(dirname "$common")"
reg="${XDG_CONFIG_HOME:-$HOME/.config}/ai-kit/projects.tsv"
[ -f "$reg" ] || exit 1
kit="$(awk -F'\t' -v r="$root" '$1==r {print $2}' "$reg" | tail -1)"
[ -n "$kit" ] && [ -f "$kit/.ai/lib.sh" ] || exit 1
echo "$kit"
