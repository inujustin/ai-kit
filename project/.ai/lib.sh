# Sourced by every kit script. The kit lives OUTSIDE the project repo; nothing of it is copied into the repo.
#   KIT      this project's kit folder (the one holding .ai/), found from the script's own location
#   ROOT     the project repo's folder, found from the current directory
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")" \
  || { echo "Run this from inside the project repo." >&2; exit 1; }
export KIT ROOT

# Base branch of the current branch: `git config branch.<b>.aibase` if the user set one, else the first of
# develop/main/master that exists. Used by verify (changed files) and gate (review range).
kit_base() {
  local b; b="$(git config "branch.$(git branch --show-current).aibase" 2>/dev/null)" && { echo "$b"; return; }
  for b in develop main master; do git rev-parse -q --verify "refs/heads/$b" >/dev/null && { echo "$b"; return; }; done
  echo HEAD
}
