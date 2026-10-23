# Rule → hook: when text is not enough

Text rules (CLAUDE.local.md, AGENTS.md, skills) need judgement and get forgotten when they are long or repeated.
Hooks are code Claude Code runs on every matching event, so they cannot be forgotten. Rule of thumb
(from Anthropic's context-engineering guidance: judgement in text, progressive disclosure, no repetition):
- Needs judgement ("match the surrounding style") → keep as text, short, in one place.
- Mechanical and checkable ("never commit on main", "run lint after edit", "no frappe.db.commit in controllers")
  → hook or a CI grep rule in the active pack.

## Signals that a rule should become a hook
- The user had to repeat it, or you broke it once already.
- It lives in a skill or guide too long to read every time, or it is stated in more than one file.
- It can be checked by a command or a grep with few false positives.

## Proactive scan (the user will not notice candidates; you must)
Do a scan and show the result as one AskUserQuestion with `multiSelect` ("Which of these should become hooks?",
each option = one rule + one line on what the hook would do), at these moments:
- kit onboarding and "review the kit" (scan AGENTS.md, CLAUDE.local.md, the team's CLAUDE.md, active packs, installed skills);
- `/retro` and the end of a long task;
- whenever you read a skill or guide longer than ~150 lines, or see the same rule in two files;
- whenever a signal below shows up during work.
The SessionStart hook (`.ai/hooks/session-start.sh`) reminds you of candidates still marked "not now".

## What to do (every time a signal shows up)
1. Ask the user with AskUserQuestion: the rule, where it lives, the signal, what the hook would do
   (event: PreToolUse / PostToolUse / Stop / SessionStart; what it checks; what it blocks or prints), the cost
   (false positives, speed). Options: "make the hook now" (recommended when the check is clear) / "not now" /
   "no for this whole session".
2. "not now": log it below and ask again next time it shows up. "no for this whole session": stop asking until the
   session ends (it is not a permanent no).
3. "make the hook now": write it in `.ai/hooks/`, wire it in `.claude/settings.local.json`, test it on a fake case,
   then remove the now-redundant text rule (one place only).

## Hooks already in this kit
| Hook | Event | Enforces |
|---|---|---|
| guard-git.sh | PreToolUse(Bash) | commit only on ai/*, no push of ai/*, no force-push, no push to main/master/develop |
| after-edit.sh | PostToolUse(Edit/Write) | the team's pre-commit hooks on the edited file |
| stop-gate.sh | Stop | `verify.sh --fast` in AI worktrees with uncommitted changes |
| git pre-push | git | ai/* branches never leave the machine (also for the user) |
| session-start.sh | SessionStart | reminds Claude of hook candidates still "not now" and of the ask-first rules |

## Candidates log
| Date | Rule | Where it lives | Signal | Decision |
|---|---|---|---|---|
