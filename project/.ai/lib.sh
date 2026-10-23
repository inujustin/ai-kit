# Sourced by every kit script. The kit lives OUTSIDE the project repo; nothing of it is copied into the repo.
#   KIT      this project's kit folder (the one holding .ai/), found from the script's own location
#   ROOT     the project repo's main folder (works from any of its worktrees), found from the current directory
#   WT_DIR   where AI worktrees live: inside the kit, never inside the repo
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")" \
  || { echo "Run this from inside the project repo (or one of its worktrees)." >&2; exit 1; }
WT_DIR="$KIT/worktrees"
export KIT ROOT WT_DIR
