#!/usr/bin/env bash
# SessionStart: plain stdout becomes Claude's context. If this repo has a registered kit (kept outside the repo),
# load its rules here, so the user just types `claude` in the repo. Also list the repo's own rule files: team rules win,
# and any conflict between them and the kit is a question for the user, never a silent choice.
here="$(dirname "$0")"
input="$(cat)"
cwd="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)"
sid="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("session_id",""))' 2>/dev/null)"
cwd="${cwd:-$PWD}"
root="$(dirname "$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"

if ! kit="$(bash "$here/kit-resolve.sh" "$cwd")"; then
  if [ -n "$root" ] && [ "$root" != "." ]; then
    echo "ai-kit: no kit registered for this repo ($root). If the user works on this project, offer once: \"setup the kit for this project\" (see ~/ai-kit-src or ~/ai-kit SETUP.md Phase 5)."
  fi
  exit 0
fi

echo "ai-kit: this repo's kit is KIT=$kit (outside the repo; nothing of it is in the repo)."
# A developer or reviewer the lead started: its prompt carries the role and the rules to read; skip the lead's ~4k
# tokens of user-facing rules, profile questions and reminders (they do not apply and they cost every session)
if [ -n "${AI_KIT_DELEGATE:-}" ] && [ "${AI_FRESH:-}" != 1 ]; then
  echo "You were started by this project's lead for one role; follow your prompt. Project rules: $kit/AGENTS.md and the repo's CLAUDE.md. Ask nothing: list open questions in your final message."
  exit 0
fi
echo "In the rules below, every path starting with .ai/ or AGENTS.md means \$KIT/... ; run kit scripts as bash $kit/.ai/bin/<name> from the repo."
echo
echo "Rule files this repo already has (team rules: they win over the kit; on any conflict ask the user, do not decide):"
found=0
for f in CLAUDE.md AGENTS.md .claude/CLAUDE.md CONTRIBUTING.md .github/copilot-instructions.md .cursorrules .editorconfig \
         .pre-commit-config.yaml pyproject.toml .eslintrc .eslintrc.json .eslintrc.js eslint.config.js eslint.config.mjs \
         .prettierrc .prettierrc.json commitlint.config.js .commitlintrc .commitlintrc.json .gitmessage; do
  [ -e "$root/$f" ] && { echo "  - $f"; found=1; }
done
for d in .cursor/rules .claude/rules docs/adr; do [ -d "$root/$d" ] && { echo "  - $d/"; found=1; }; done
[ $found -eq 1 ] || echo "  (none found)"
echo
for f in CLAUDE.local.md AGENTS.md; do
  [ -f "$kit/$f" ] && { echo "===== kit $f ====="; cat "$kit/$f"; echo; }
done
if [ -f "$kit/.ai/run/tasks.json" ]; then
  st="$(python3 "$kit/.ai/bin/run" status 2>/dev/null)"
  if ! printf '%s' "$st" | grep -q "nothing left" || printf '%s' "$st" | grep -q "^blocked:"; then
    echo "ai-kit: a long run is in progress. Get up to speed first (\$KIT/.ai/LONGRUN.md): read \$KIT/.ai/run/progress.md and git log, then:"
    printf '%s\n' "$st" | sed 's/^/  /'
  fi
fi
# Opened kit or unattended run: the user is away or asked for no popups, so no session-start questions.
quiet=no
if o="$(bash "$here/open-state.sh" "$kit")"; then
  quiet=yes; echo "ai-kit: this kit is OPEN until $(date -d "@${o%% *}" '+%Y-%m-%d %H:%M') (${o#* }): guards act like the loose global defaults; back to mode.conf by itself after that."
fi
[ -e "$kit/.ai/run/auto" ] && quiet=yes
[ "${AI_FRESH:-}" = 1 ] && quiet=yes   # one task of a bin/fresh run: the user is away
if l="$(cat "$kit/.ai/run/lead" 2>/dev/null)" && [ "${l%% *}" != "$sid" ] && [ -z "${AI_KIT_DELEGATE:-}" ] \
   && [ $(( $(date +%s) - ${l##* } )) -lt $(( ${AI_LEAD_TTL_MIN:-30} * 60 )) ]; then
  echo "ai-kit: another session (${l:0:8}) was the lead of this project in the last ${AI_LEAD_TTL_MIN:-30} min. One lead per project: if it is still working, tell the user in one line and do read-only work only; guard-lead asks before any edit here."
fi
[ -f "$kit/.ai/LESSONS.md" ] && echo "ai-kit: read \$KIT/.ai/LESSONS.md first (past mistakes in this project and the rule for each)."
[ "$quiet" = yes ] && echo "ai-kit: ask nothing at session start (open or unattended): keep the profile, decide yourself, log decisions in the footprint." && exit 0
if [ -x "$kit/.ai/bin/test-scan" ]; then
  TEST_POLICY=ask; [ -f "$kit/.ai/mode.conf" ] && . "$kit/.ai/mode.conf"
  echo "ai-kit: $(cd "$root" && bash "$kit/.ai/bin/test-scan" 2>/dev/null | head -1); TEST_POLICY=$TEST_POLICY. At the first code task of this session ask the user (AskUserQuestion) whether to write tests (recommend yes if the repo has tests, skip with manual checks if not)."
fi
if [ -f "$kit/.ai/mode.conf" ]; then
  BUDGET=normal; BRANCHES=ask; REMOTE=ask; . "$kit/.ai/mode.conf"
  echo "ai-kit: work profile BUDGET=$BUDGET BRANCHES=$BRANCHES REMOTE=$REMOTE PROVIDERS=\"${PROVIDERS:-claude codex}\" TEST_POLICY=${TEST_POLICY:-ask}, now on branch $(git -C "$root" branch --show-current 2>/dev/null). It is never fixed: at the first task of this session show it in plain words and ask (AskUserQuestion, with the tests question) whether it still fits; write changes to \$KIT/.ai/mode.conf."
fi
if [ -f "$kit/.ai/mode.conf" ]; then
  ACCOUNT_GROUP=""; . "$kit/.ai/mode.conf"
  [ -z "$ACCOUNT_GROUP" ] && echo "ai-kit: ACCOUNT_GROUP is empty for this project: with the profile question, ask which account group it uses (facts: bash $kit/.ai/bin/account list); flexible, re-ask when it looks wrong."
fi
if [ -f "$kit/.ai/bin/projects" ]; then
  busy="$(python3 "$kit/.ai/bin/projects" --json 2>/dev/null | python3 -c 'import json,sys; r=json.load(sys.stdin); print(sum(1 for x in r if x["auto_run"] or x["tasks"].get("in_progress")))' 2>/dev/null)"
  if [ "${busy:-0}" -gt 1 ]; then
    echo "ai-kit: $busy projects on this machine have long runs going (python3 $kit/.ai/bin/projects). One AI team per project: never read or mix the other projects' code or notes. Priority is yours to decide when PRIORITY=auto: use that table, say your choice in one line, and when quota is short tell the user which project should yield. At most once a day while several run, check official sources (Anthropic and OpenAI docs on usage limits, rate limits, scheduling long agent runs) for anything new and log it in \$KIT/.ai/PRACTICES.md; search with general words only, never project names or details."
  fi
fi
pending=0
[ -f "$kit/.ai/HOOKS.md" ] && pending=$(sed -n '/^## Candidates log/,$p' "$kit/.ai/HOOKS.md" | grep -ci '| *not now *|$')
[ "$pending" -gt 0 ] && echo "ai-kit: $pending hook candidate(s) in \$KIT/.ai/HOOKS.md are 'not now': ask the user again when they come up."
open_bp=0
[ -f "$kit/.ai/PRACTICES.md" ] && open_bp=$(sed -n '/^## Catalog/,/^## Leads/p' "$kit/.ai/PRACTICES.md" | grep -ciE '\| *(proposed|not now) *\|$')
[ -s "$kit/.ai/handoff.md" ] && echo "ai-kit: a session handoff exists: read \$KIT/.ai/handoff.md first and tell the user in one line where the last session stopped."
[ "$open_bp" -gt 0 ] && echo "ai-kit: $open_bp best practice(s) in \$KIT/.ai/PRACTICES.md are proposed or 'not now': when one fits the work, grill the user about it."
exit 0
