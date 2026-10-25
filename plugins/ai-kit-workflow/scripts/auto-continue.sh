#!/usr/bin/env bash
# Stop: keep an approved long run going without the user typing anything. Active only while $KIT/.ai/run/auto exists
# (created after the user says "run unattended", see LONGRUN.md). Starts the next task from `run status`; stops by itself
# when nothing is left, only blocked tasks remain, or AI_AUTO_MAX_TURNS (default 30) turns were used.
input=$(cat)
cwd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)
kit="$(bash "$(dirname "$0")/kit-resolve.sh" "${cwd:-$PWD}")" || exit 0
flag="$kit/.ai/run/auto"; [ -e "$flag" ] || exit 0
turns_f="$kit/.ai/run/auto-turns"; turns=$(( $(cat "$turns_f" 2>/dev/null || echo 0) + 1 )); echo "$turns" > "$turns_f"
max="${AI_AUTO_MAX_TURNS:-30}"
st="$(python3 "$kit/.ai/bin/run" status 2>/dev/null)"
# On stop: the run's temporary push permission ends with it, and Claude must report before it stops (once: the flag is gone).
stop_run() {
  rm -f "$flag" "$turns_f" "$kit/.ai/run/allow-push"; python3 "$kit/.ai/bin/run" note "auto run stopped: $1" >/dev/null 2>&1
  python3 -c 'import json,sys; print(json.dumps({"decision":"block","reason":"Auto run stopped (%s). Before stopping, write the end-of-run report for the user (they read it later, e.g. in the morning), short and plain, in their language: each branch touched with its new commits (git log --oneline <base>..<branch>), what passed and how it was checked, what was pushed and what is still local, blocked tasks and the decisions only they can make (then ask them with AskUserQuestion), and the next step. Update $KIT/.ai/handoff.md with the same. Push nothing more now." % sys.argv[1]}))' "$1"
  exit 0
}
[ "$turns" -gt "$max" ] && stop_run "turn budget $max used; tell the user where it stands and ask whether to continue"
printf '%s' "$st" | grep -q "nothing left" && stop_run "no runnable task left"
next="$(printf '%s' "$st" | sed -n 's/^next: //p')"
python3 -c 'import json,sys; print(json.dumps({"decision":"block","reason":"Auto run (turn %s of %s): continue with the next task: %s. Follow $KIT/.ai/LONGRUN.md (one task, checks, run pass/block, commit, run note). A decision only the user can make: ask with AskUserQuestion. Stop the run early: rm $KIT/.ai/run/auto." % (sys.argv[1], sys.argv[2], sys.argv[3])}))' "$turns" "$max" "$next"
exit 0
