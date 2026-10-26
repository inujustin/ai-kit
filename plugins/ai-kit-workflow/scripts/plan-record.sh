#!/usr/bin/env bash
# PostToolUse(ExitPlanMode): every plan that leaves plan mode is kept, like a footprint is kept for a change.
# Kit repo: $KIT/.ai/plans/<date>-<slug>.md + one line in plans/INDEX.md (never in the repo).
# No kit: ~/.local/state/ai-kit/plans/<repo>/ (same layout). Tells Claude the file so the footprint can link it.
input=$(cat)
cwd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null); cwd="${cwd:-$PWD}"
root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || echo "$cwd")"
if kit="$(bash "$(dirname "$0")/kit-resolve.sh" "$cwd" 2>/dev/null)"; then dir="$kit/.ai/plans"
else dir="${XDG_STATE_HOME:-$HOME/.local/state}/ai-kit/plans/$(basename "$root")"; fi
printf '%s' "$input" | DIR="$dir" BRANCH="$(git -C "$cwd" branch --show-current 2>/dev/null)" python3 -c '
import json, os, re, sys, datetime
d = json.load(sys.stdin)
plan = (d.get("tool_input") or {}).get("plan", "").strip()
if not plan:
    sys.exit(0)
title = next((re.sub(r"^#+\s*", "", l).strip() for l in plan.splitlines() if l.strip()), "plan")[:80]
slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:40] or "plan"
now = datetime.datetime.now(); dr = os.environ["DIR"]; os.makedirs(dr, exist_ok=True)
name = f"{now:%Y-%m-%d-%H%M}-{slug}.md"; path = os.path.join(dr, name)
br = os.environ.get("BRANCH") or "-"
open(path, "w").write(f"<!-- plan recorded {now:%Y-%m-%d %H:%M} · branch {br} · status: approved -->\n{plan}\n")
idx = os.path.join(dr, "INDEX.md")
if not os.path.exists(idx):
    open(idx, "w").write("# Plans: what was planned before each execution (newest last)\nOne line per plan: date · title · branch · file · status (approved / done / dropped).\n\n")
open(idx, "a").write(f"- {now:%Y-%m-%d %H:%M} · {title} · {br} · {name} · approved\n")
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext":
    f"ai-kit: plan recorded at {path}. Link it from the footprint of this work; when done or dropped, set its status in {idx}."}}))
'
exit 0
