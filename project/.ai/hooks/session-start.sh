#!/usr/bin/env bash
# SessionStart: stdout is added to Claude's context. Reminds Claude of the ask-first rules and of hook candidates
# the user answered "not now" to (rows in .ai/HOOKS.md "Candidates log" whose Decision says "not now").
root="${CLAUDE_PROJECT_DIR:-.}"
log="$root/.ai/HOOKS.md"
pending=0
if [ -f "$log" ]; then
  pending=$(sed -n '/^## Candidates log/,$p' "$log" | grep -ci '| *not now *|$')
fi
echo "ai-kit: ask before acting on rule conflicts; explain every question and permission in one plain line; pick skills yourself and ask when unsure."
if [ "$pending" -gt 0 ]; then
  echo "ai-kit: $pending hook candidate(s) in .ai/HOOKS.md are marked 'not now'. Ask the user about them again when they come up (multiSelect)."
fi
exit 0
