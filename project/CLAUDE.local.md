# Private AI kit (Claude only, never committed)

The team's `CLAUDE.md` (if any) wins over this file. Shared rules: @AGENTS.md · Skill map: @.ai/SKILLS.md
Read when relevant: `.ai/WORKFLOW.md` (roles, Codex, separate contexts, git, push/PR) · `.ai/HOOKS.md` (rule → hook)
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
