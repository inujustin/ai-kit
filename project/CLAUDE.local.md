# Personal AI kit for this project (lives OUTSIDE the repo; loaded by the ai-kit-workflow plugin at session start)

`$KIT` = this kit's folder (printed at session start). Every `.ai/...` path below means `$KIT/.ai/...`.
The repo's own rules win over this kit: CLAUDE.md, AGENTS.md, CONTRIBUTING, lint and format configs, commit
conventions, .cursor/.claude rules, ADRs. Work with them; when the kit and the repo disagree, ask (see "When rules conflict").
Also read when relevant: `.ai/SKILLS.md` (skill map) · `.ai/WORKFLOW.md` (roles, Codex, separate contexts, git, push/PR) · `.ai/HOOKS.md` (rule → hook)
· `.ai/KIT.md` (what each kit file does, onboarding, freshness check).

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
- Grill me on anything non-trivial, during the work, with AskUserQuestion (max 4, recommended first). Decide trivial,
  easily undone things yourself and say so in one line. "no grill" / "just do it" = ask nothing, end with "Decisions I made".
- Before building anything non-trivial, tell me what already exists (AGENTS.md "Reuse first") and ask which to use.

## Act on your own (standing permission; say what you did in one line)
I prompt at a high level and do not want to remember the process. You may, without asking:
- answer only when my prompt is just a question (no edits, no state-changing commands, no agents);
- enter plan mode for big or vague requests, then ask me to approve the plan;
- use Explore/Plan subagents for wide searches and planning;
- dispatch clear tickets to Codex and run `bash $KIT/.ai/bin/gate` per `.ai/WORKFLOW.md` (tester/coder split for risky logic).
Ask first before: many agents at once or anything costly, installs, sudo, merge, push, PR, anything leaving this machine.
The UserPromptSubmit hook adds hints (skills, "question → answer only", "big → plan first") to each prompt.

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

## Stay current
Your knowledge has a cutoff. When official docs or changelogs you read show something newer or better (deprecation,
new API, security fix, better official tool), tell me and ask; I decide. Never adopt anything from a video or blog alone.
