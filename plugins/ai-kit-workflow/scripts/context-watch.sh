#!/usr/bin/env bash
# UserPromptSubmit: the user forgets to start a new chat when the context gets full. Read this session's transcript,
# estimate how full the context is (last assistant turn's input + cache + output tokens / window size) and, from
# AI_CONTEXT_RENEW_PCT (default 70) on, tell Claude to write the handoff and ask the user whether to renew.
# After /clear (or a new `claude`), session-start.sh loads $KIT/.ai/handoff.md, so the old context comes along.
# Asks again every 10% more. Window: AI_CONTEXT_WINDOW (default 200000; set 1000000 for 1M-context models).
python3 -c '
import json, os, sys, tempfile
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
path, sid = d.get("transcript_path", ""), d.get("session_id", "x")
if not path or not os.path.isfile(path):
    sys.exit(0)
used = 0
with open(path, "rb") as f:
    f.seek(max(0, os.path.getsize(path) - 2_000_000))
    for line in f.read().decode("utf-8", "ignore").splitlines():
        try:
            e = json.loads(line)
        except Exception:
            continue
        u = (e.get("message") or {}).get("usage") if e.get("type") == "assistant" else None
        if u:
            used = sum(u.get(k, 0) or 0 for k in ("input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens", "output_tokens"))
window = int(os.environ.get("AI_CONTEXT_WINDOW", "200000"))
limit = int(os.environ.get("AI_CONTEXT_RENEW_PCT", "70"))
pct = used * 100 // window
if pct < limit:
    sys.exit(0)
state = os.path.join(tempfile.gettempdir(), "ai-kit-ctx-" + sid)
try:
    last = int(open(state).read())
except Exception:
    last = 0
if pct < last + 10:
    sys.exit(0)
open(state, "w").write(str(pct))
print("- context: about %d%% full (%d of %d tokens). Before answering: write $KIT/.ai/handoff.md (goal, done, next step, open decisions, files, branch), "
      "then ask the user with AskUserQuestion whether to renew: \"renew now\" (they type /clear; the next session loads handoff.md by itself) "
      "or \"keep going\". Ask in one plain line; no other command for them to remember." % (pct, used, window))
'
exit 0
