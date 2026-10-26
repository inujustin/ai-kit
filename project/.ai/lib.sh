# Sourced by every kit script. The kit lives OUTSIDE the project repo; nothing of it is copied into the repo.
#   KIT      this project's kit folder (the one holding .ai/), found from the script's own location
#   ROOT     the project repo's folder, found from the current directory; outside any repo, the repo registered for
#            this kit in ~/.config/ai-kit/projects.tsv (and the script moves there), so `bash $KIT/.ai/bin/...` works
#            from any folder and still matches the plain allow rules (no `cd`/`env` prefix, no popup)
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  registered="$(awk -F'\t' -v kit="$KIT" '$2 == kit { print $1; exit }' "$HOME/.config/ai-kit/projects.tsv" 2>/dev/null)"
  cd "${registered:-/nonexistent}" 2>/dev/null || { echo "Run this from inside the project repo." >&2; exit 1; }
fi
ROOT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
export KIT ROOT

# A fresh headless Claude session with its own context (prompt on stdin), for bin/fresh, dispatch and gate:
#   claude_session <out-file> <claude args...>
# Writes the session's final message to <out-file> (raw result in <out-file>.json, stderr in <out-file>.err).
# Returns 0 done, 3 out of quota, 1 failed. Quota is read from the structured result, never from the transcript.
# Done = exit 0 AND a complete result with subtype "success". AI_KIT_DELEGATE=<this kit> lets the session work in this
# project while the lead holds it (guard-lead), never in another one. Cost of each session: $KIT/.ai/run/costs.tsv.
claude_session() {
  local out="$1" rc=0; shift
  AI_KIT_DELEGATE="$KIT" claude -p --permission-prompts none --add-dir "$KIT" --output-format json "$@" \
    >"$out.json" 2>"$out.err" || rc=$?
  python3 - "$out.json" "$out" "$rc" "$KIT/.ai/run/costs.tsv" <<'PY'
import datetime, json, os, re, sys
src, dst, rc, costs = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
raw = open(src).read()
try:
    r = json.loads(raw)
except Exception:
    try:
        r = json.loads(raw.strip().splitlines()[-1])
    except Exception:
        open(dst, "w").write(raw); sys.exit(1)
if isinstance(r, list):   # multi-turn sessions print every message; the result is the last "result" one
    r = next((m for m in reversed(r) if isinstance(m, dict) and m.get("type") == "result"), {})
if not isinstance(r, dict):
    open(dst, "w").write(raw); sys.exit(1)
text = str(r.get("result") or "")
open(dst, "w").write(text + "\n")
u = r.get("usage") or {}
os.makedirs(os.path.dirname(costs), exist_ok=True)
with open(costs, "a") as f:
    f.write("\t".join(str(x) for x in (datetime.datetime.now().strftime("%Y-%m-%d %H:%M"), os.path.basename(dst),
        ",".join(r.get("modelUsage") or {}) or "?", r.get("total_cost_usd", 0), u.get("input_tokens", 0),
        u.get("cache_read_input_tokens", 0), u.get("cache_creation_input_tokens", 0), u.get("output_tokens", 0))) + "\n")
if rc == 0 and r.get("type") == "result" and r.get("subtype") == "success" and not r.get("is_error"):
    sys.exit(0)
quota = r.get("api_error_status") == 429 or re.search(r"hit your limit|usage limit|rate limit|quota|limit reached", text, re.I)
sys.exit(3 if r.get("is_error") and quota else 1)
PY
}

# Base branch of the current branch: `git config branch.<b>.aibase` if the user set one, else the first of
# develop/main/master that exists. Used by verify (changed files) and gate (review range).
kit_base() {
  local b; b="$(git config "branch.$(git branch --show-current).aibase" 2>/dev/null)" && { echo "$b"; return; }
  for b in develop main master; do git rev-parse -q --verify "refs/heads/$b" >/dev/null && { echo "$b"; return; }; done
  echo HEAD
}
