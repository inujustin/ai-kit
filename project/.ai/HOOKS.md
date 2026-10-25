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
- A skill keeps being used for the same mechanical check (lint, a rule, a format, a guard): a hook does it every time
  without anyone remembering; ask whether to move it from skill to hook.

## Proactive scan (the user will not notice candidates; you must)
Do a scan and show the result as one AskUserQuestion with `multiSelect` ("Which of these should become hooks?",
each option = one rule + one line on what the hook would do), at these moments:
- kit onboarding and "review the kit" (scan AGENTS.md, CLAUDE.local.md, the team's CLAUDE.md, active packs, installed skills);
- the weekly look-back and the end of a long task;
- whenever you read a skill or guide longer than ~150 lines, or see the same rule in two files;
- whenever a signal below shows up during work.
The SessionStart hook of the ai-kit-workflow plugin reminds you of candidates still marked "not now".

## What to do (every time a signal shows up)
1. Ask the user with AskUserQuestion: the rule, where it lives, the signal, what the hook would do
   (event: PreToolUse / PostToolUse / Stop / SessionStart; what it checks; what it blocks or prints), the cost
   (false positives, speed). Options: "make the hook now" (recommended when the check is clear) / "not now" /
   "no for this whole session".
2. "not now": log it below and ask again next time it shows up. "no for this whole session": stop asking until the
   session ends (it is not a permanent no).
3. "make the hook now": always inside THIS project's kit, never in the shared ai-kit source:
   - a greppable code rule → a line in the active pack's antipatterns.rules.sh (runs in verify);
   - anything else → a script `$KIT/.ai/hooks/<Event>/<name>.sh` (Event = SessionStart, UserPromptSubmit, PreToolUse,
     PostToolUse or Stop; stdin = the hook JSON; exit 2 blocks and shows stderr). The plugin runs it for this project only.
   Test it on a fake case, then remove the now-redundant text rule (one place only).
   If it would help every project, say so and stop there: the user promotes it from a session opened inside ~/ai-kit.

## Hooks already in this kit
| Hook | Event | Enforces |
|---|---|---|
| plugin guard-outside.sh | PreToolUse(Read/Edit/Write/Glob/Grep/Bash) | outside the workspace and, on WSL, the Windows side (/mnt, *.exe): always a popup with the full explanation (also in auto mode); bulk deletes/moves there denied |
| plugin guard-git.sh | PreToolUse(Bash) | per mode.conf: branch switch/create/delete, every remote command, reset --hard, clean, rebase, merge, clone, worktree add → popup with the full explanation (BRANCHES=auto / REMOTE=feature let some pass); refused: force-push, push --all/--mirror, push to protected branches, commits on protected branches, kit files in a commit, subjects off commit-style.conf |
| plugin guard-repo.sh | PreToolUse(Edit/Write/Bash) | no whole-repo fixers in the repo; a project session never edits the ai-kit source |
| plugin after-edit.sh | PostToolUse(Edit/Write) | the team's pre-commit hooks on the edited file |
| plugin stop-gate.sh | Stop | `verify.sh --fast` when the repo has uncommitted changes |
| plugin session-start.sh | SessionStart | loads this kit's rules, lists the repo's own rule files, reminds of "not now" hook candidates and open best practices |
| plugin auto-continue.sh | Stop | approved long run only ($KIT/.ai/run/auto): start the next task; stop when none left, only blocked, or AI_AUTO_MAX_TURNS used |
| plugin context-watch.sh | UserPromptSubmit | context about 70% full (AI_CONTEXT_RENEW_PCT, AI_CONTEXT_WINDOW): write handoff.md, ask whether to renew; again every +10% |
| plugin prompt-skills.sh | UserPromptSubmit | reads each prompt, prints skill hints by keyword (VI + EN) so skills are picked even for short high-level prompts; reminds to check PRACTICES.md and to log pasted tips as leads; grills the work profile (budget, branches, remote) each session and when the prompt brings them up |

## Candidates log
| Date | Rule | Where it lives | Signal | Decision |
|---|---|---|---|---|
