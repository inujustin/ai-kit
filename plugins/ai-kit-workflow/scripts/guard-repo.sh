#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit|NotebookEdit|Bash): the team's repo is not ours to change during AI work.
# In a repo with a registered kit, Claude edits files only inside its ai/* worktrees (in the kit), never in the team's
# main checkout, and never runs whole-repo fixers (pre-commit --all-files, formatters with --write/--fix) there.
# The user can lift this for a while by creating $KIT/.ai/allow-root-edits (and delete it afterwards).
input=$(cat)
read_json() { printf '%s' "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print($1)" 2>/dev/null; }
tool=$(read_json 'd.get("tool_name","")')
cwd=$(read_json 'd.get("cwd","")'); cwd="${cwd:-$PWD}"
kit="$(bash "$(dirname "$0")/kit-resolve.sh" "$cwd")" || exit 0
allow_root=no; [ -e "$kit/.ai/allow-root-edits" ] && allow_root=yes
root="$(dirname "$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)")"
block() { echo "Blocked by ai-kit guard-repo: $1 Work in an ai/* worktree (bash $kit/.ai/bin/newsession claude <name>), or ask the user to allow edits by creating $kit/.ai/allow-root-edits." >&2; exit 2; }
in_root() { case "$(realpath -m "$1")/" in "$root"/*) return 0 ;; *) return 1 ;; esac; }

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    f=$(read_json 'd.get("tool_input",{}).get("file_path") or d.get("tool_input",{}).get("notebook_path") or ""')
    [ -n "$f" ] || exit 0
    case "$f" in /*) ;; *) f="$cwd/$f" ;; esac
    # A project session never changes the shared ai-kit source; that happens only in a session opened inside it.
    src="$(cat "${XDG_CONFIG_HOME:-$HOME/.config}/ai-kit/source" 2>/dev/null)"
    if [ -n "$src" ]; then case "$(realpath -m "$f")/" in "$src"/*)
      echo "Blocked by ai-kit guard-repo: $f is in the shared ai-kit source ($src). A project's changes stay in its own kit ($kit): project hooks go in $kit/.ai/hooks/<Event>/. To change the kit for every project, the user opens claude inside $src and asks there." >&2; exit 2 ;; esac; fi
    [ "$allow_root" = no ] && in_root "$f" && block "$f is in the team's checkout ($root)."
    ;;
  Bash)
    cmd=$(read_json 'd.get("tool_input",{}).get("command","")')
    printf '%s' "$cmd" | grep -qE 'pre-commit[[:space:]]+run([^|;&]*(--all-files|[[:space:]]-a([[:space:]]|$)))|ruff[[:space:]]+format|ruff[[:space:]]+check[^|;&]*--fix|black[[:space:]]|isort[[:space:]]|prettier[^|;&]*--write|eslint[^|;&]*--fix|npm[[:space:]]+run[[:space:]]+(format|lint:fix)|yarn[[:space:]]+(format|lint:fix)' || exit 0
    dir=$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+("?)([^"[:space:]&;]+)\1.*/\2/p'); dir="${dir:-$cwd}"
    case "$dir" in /*) ;; *) dir="$cwd/$dir" ;; esac
    [ "$allow_root" = no ] && in_root "$dir" && block "whole-repo fixers would rewrite the team's files."
    ;;
esac
exit 0
