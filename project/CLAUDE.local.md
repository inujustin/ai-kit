# Personal AI kit for this project (lives OUTSIDE the repo; loaded by the ai-kit-workflow plugin at session start)

`$KIT` = this kit's folder (printed at session start). Every `.ai/...` path below means `$KIT/.ai/...`.
The repo's own rules win over this kit: CLAUDE.md, AGENTS.md, CONTRIBUTING, lint and format configs, commit
conventions, .cursor/.claude rules, ADRs. Work with them; when the kit and the repo disagree, ask (see "When rules conflict").
Also read when relevant: `.ai/SKILLS.md` (skill map) · `.ai/WORKFLOW.md` (roles, Codex, separate contexts, git, push/PR) · `.ai/HOOKS.md` (rule → hook)
· `.ai/KIT.md` (what each kit file does, onboarding, freshness check) · `.ai/PRACTICES.md` (best practices to grill me about).

## First session in this project (do it, then delete this section)
The kit was just copied in. Run the onboarding in `.ai/KIT.md` with me before any other work.

## Talking to me
- My language (Vietnamese by default), short, plain words; keep technical terms.
- I read popups, not long chat. Every permission popup and every question carries its own brief explanation:
  - permission (Bash `description`, or one line before Write/Edit): what it does, what it changes, why it is needed,
    whether it touches anything remote, how to undo, which option to pick ("Chọn Yes").
  - question: one plain sentence, 2–4 options each with what happens if I pick it, recommended first, understandable alone.
  - never chain many steps into one permission; split them.
- Skills: I talk normally and do not remember names. At the start of each task, check `.ai/SKILLS.md` and the installed
  skills yourself, invoke the ones that fit, and say in one line which. When a skill might fit but you are unsure, when
  two skills disagree, or when a skill that is not installed would clearly help, ask me (what it adds, cost, source).
- Grill me on anything non-trivial, during the work, with AskUserQuestion (max 4, recommended first). Never ask me a
  question inside reply text; always the AskUserQuestion popup. Decide trivial,
  easily undone things yourself and say so in one line. "no grill" / "just do it" = ask nothing, end with "Decisions I made".
- Before building anything non-trivial, tell me what already exists (AGENTS.md "Reuse first") and ask which to use.

## Act on your own (standing permission; say what you did in one line)
I prompt at a high level and do not want to remember the process. You may, without asking:
- answer only when my prompt is just a question (no edits, no state-changing commands, no agents);
- enter plan mode for big or vague requests, then ask me to approve the plan;
- use Explore/Plan subagents for wide searches and planning;
- dispatch tickets to Codex and run `bash $KIT/.ai/bin/gate` per `.ai/WORKFLOW.md` (planner, developer and reviewer are
  separate contexts, a tester only when the ticket says `Tests: write`; you choose how many agents and at what effort).
- Tests: never decide alone. Ask me often (start of each session, each ticket) with the facts from `.ai/bin/test-scan`:
  the repo has tests → recommend writing them; none → recommend skipping with manual checks.
Ask first before: many agents at once or anything costly, installs, sudo, merge, push, PR, anything leaving this machine.
The UserPromptSubmit hook adds hints (skills, "question → answer only", "big → plan first") to each prompt.

## The team's repo is hands-off
I am a contributor, not the owner. Setup and onboarding only READ the repo. Code changes follow `.ai/mode.conf`: direct =
on my current feature branch, one local commit per finished step (never on protected branches); worktree = only in your
ai/* worktrees. In every mode: never run whole-repo fixers (pre-commit --all-files,
formatters with --write/--fix) on it; `.ai/verify.sh` already runs on a throw-away copy. Team rules, CI, infra and config
files change only when I ask for that exact change, as a normal contribution through review. The plugin's guard-repo hook
enforces this; I can lift it for a while with `touch $KIT/.ai/allow-root-edits`.

## Plans and tickets never enter the repo
Plans live only on this machine (`~/.claude/plans/`); tickets, specs, glossary and ADR drafts live in the kit
(`$KIT/.ai/tickets/`, `$KIT/.ai/docs/`). No plan or ticket file is ever committed or pushed. Only the code of each ticket
enters the repo: ai/* branch → story commits → my review. Commit messages and PR bodies describe the change, not the plan file.

## Commits and branches
- Break work into small commits, one logical step each, in an order a reviewer can follow; never one big commit.
- Stay on the branch I am on. Never `git switch` / `git checkout <branch>` on your own (the guard-git hook blocks it);
  changing branch is my decision, ask with AskUserQuestion.

## This kit is self-contained
Everything you add for this project (rules, hooks, packs, commit style, notes) goes into THIS kit (`$KIT`), never into the
shared ai-kit source (~/ai-kit, blocked by the guard-repo hook) and never into the repo. If something would help every
project, tell me; I promote it myself from a session opened inside ~/ai-kit.

## Risk rule (everything you do)
- Safe (read-only, local, easy to undo): just do it and say it in one line. E.g. reading, searching, `git pull` of ai-kit,
  doctor, running tests/verify, planning, subagents for research, commits on your own ai/* branch.
- Risky: ask first with AskUserQuestion: what changes, why, how to undo. E.g. installing or updating plugins, tools or
  packages (new code that runs), sudo, merging into or rewriting my branches, push, PR, deleting, overwriting a file I
  edited, editing global settings or ~/.claude/CLAUDE.md, anything that leaves this machine, many agents or costly runs.
- Unsure which it is: treat it as risky.

## When rules conflict: stop and ask
Sources can disagree: the team's rules, this kit, a pack, a skill or plugin (e.g. ponytail vs the team's style),
my request, or what the real code does. When two of them point different ways, do not pick silently:
1. Ask with AskUserQuestion. In 2–3 plain lines show rule A and rule B side by side, where each comes from
   (file:line or skill name), and what each would do to this task.
2. Recommend one (default order: team rules > my explicit request > this kit > skills > habits) and say why.
3. After I choose, offer to write the decision down (AGENTS.md "Project" or the pack) so it is not asked again.

## When a rule should become a hook: keep asking
A rule belongs in a hook (code that always runs) instead of text you must remember when it is mechanical and
checkable, I had to repeat it, you forgot it, or it sits in a skill/guide too long to read every time.
Each time you notice one, ask me (rule, why, where, what the hook would do). Ask again every time it shows up,
even after "not now"; stop only after I answer "no for this whole session". Log it in `.ai/HOOKS.md`.

## Best practices: you remember them, not me
When a practice in `.ai/PRACTICES.md` fits the task and I have not decided it yet, grill me about it (that file says how).
When I paste a tip, link or screenshot, check it and add it there. Never apply one without my "apply now".

## Stay current
Your knowledge has a cutoff. When official docs or changelogs you read show something newer or better (deprecation,
new API, security fix, better official tool), tell me and ask; I decide. Never adopt anything from a video or blog alone.
