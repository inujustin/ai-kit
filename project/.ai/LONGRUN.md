# Long runs: many tasks across turns and sessions, no loops

Read when a request is big enough to need several tasks or more than one session. Based on Anthropic's
"Effective harnesses for long-running agents": a task list the agent cannot easily rewrite, a progress log, one task
at a time, verify before marking done, and a clean hand-over at the end of every session.

## Files (all in the kit, never in the repo)
- `$KIT/.ai/run/tasks.json`: the tasks. Managed only through `bash $KIT/.ai/bin/run …` (add, start, pass, block, status).
- `$KIT/.ai/run/progress.md`: dated log the run tool appends to; add your own lines with `run note "…"`.
- `$KIT/.ai/handoff.md`: snapshot for the next session (goal, done, next step, open decisions, files, branch).

## Start of a run
1. Plan (a short plan; plan mode only if the user asks), then turn the plan into tasks: `run add <id> "<what>" "<check 1>" …`. Every check says how to
   prove it works (a command and its expected output, a bench console step, a screen to click). No check, no task.
2. Ask the user (AskUserQuestion, batch into one popup): run unattended until done or stop after each task; how much
   to spend (BUDGET, model, agents, how long); which branches and whether the AI may create/switch them by itself
   (BRANCHES=auto; several branches are done in turn, never at once); may it push by itself during this run (yes =
   `touch $KIT/.ai/run/allow-push`, ends with the run; no = commit only, the user pushes later). Write the answers to
   mode.conf with the date. The run ends with a report (auto-continue asks for it). Unattended means
   `touch $KIT/.ai/run/auto`; the Stop hook then starts the next task by itself, within the limits below.

## Each task
1. Get up to speed: `run status`, the end of progress.md, `git log -5`. Check the app still starts (the kit's dev
   command in AGENTS.md); broken → fix that first as its own task.
2. `run start <id>`. One task only; ideas that come up go in as new tasks (`run add`), not into this one.
3. Developer, tester (per TEST_POLICY in mode.conf) and reviewer are separate contexts (WORKFLOW.md "Roles").
4. Verify with the task's checks. `run pass <id> "<the check you ran and what it showed>"` only after it really passed.
   Never edit, skip or delete a test or a check to make it pass.
5. Commit on the task's branch (small commits, WORKFLOW.md). A run over several branches: `run add --branch <b>`; switch
   only with a committed tree, per BRANCHES in mode.conf.

## Never loop
- `run start` refuses a third attempt (AI_MAX_ATTEMPTS, default 2). Then: one `/codex:rescue`, and if it still fails,
  `run block <id> "<why>"` and ask the user. Do not retry the same idea.
- Stop and ask the user when: a decision is theirs, a check needs them (login, data, a device), quota looks low
  (claude-hud / `/usage`), or the auto turn budget runs out (AI_AUTO_MAX_TURNS, default 30).
- Out of quota is not the end of a run: write the handoff; the user continues on the next account of the same tool
  (`$KIT/.ai/bin/ai`, pick `c`); Codex tickets switch Codex accounts by themselves only with ROTATE=auto.
- Every session ends with `run note` + an updated handoff.md, so the next session starts from facts, not memory.

## Known weakness: no automatic fresh session
The AI cannot start a new session by itself (no self `/clear`). A long run keeps going through Claude Code's
auto-compact; tasks.json, progress.md and handoff.md carry what matters, but a compacted context loses detail. So:
keep handoff.md current after every task (context-watch reminds you, silently during unattended runs), one task at a
time, and prefer small tasks. Planned fix (not built): `bin/ai` runs each task as its own fresh `claude -p` session,
which first needs a safe permission set for unattended runs. Say this plainly when the user starts an overnight run.

## `/goal` (built into Claude Code)
`/goal <condition>` keeps a session working until a checkable condition holds. Only the user can type it. Offer it as a
one-line copy-ready option when a run has a single measurable end state (e.g. "`run status` shows nothing left and
verify passes, or stop after 30 turns"); otherwise the kit's auto mode above does the same without a command.
