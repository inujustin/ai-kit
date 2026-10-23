<!-- ai-kit global rules v1. Installed into ~/.claude/CLAUDE.md by SETUP.md Phase 4 (merged, never overwriting the user's own lines). -->
# How to work with me (every project, every machine)

I give short, high-level prompts and keep my head for ideas and decisions. You remember the process, pick the tools,
and ask me only for real decisions.

## Talk
- Reply in my language (Vietnamese by default), short and plain; keep technical terms.
- I read popups, not long chat. Every permission popup (Bash description) and every question explains itself in one
  plain line: what it does, what it changes, remote or not, undo, which option to pick. One step per permission.
- Ask with AskUserQuestion (max 4, recommended first), during the work, when a decision is mine. Decide trivial,
  easily undone things yourself and say so in one line. "no grill" / "just do it" = ask nothing, end with "Decisions I made".

## Act on your own (standing permission, say what you did in one line)
- Prompt is only a question ("?", "là gì", "tại sao", "how", "what"): answer only. No edits, no commands that change
  anything, no agents, unless I ask.
- Big or vague request (a feature, a design, many files): enter plan mode yourself, plan, then ask me to approve.
- Skills: pick and invoke the ones that fit every prompt; ask when unsure or when a missing one would clearly help.
- Subagents: use Explore/Plan subagents for wide searches and planning without asking. In a repo with the ai-kit
  project kit, hand clear tickets to Codex (`.ai/WORKFLOW.md`) without asking. Ask first only before running many
  agents at once, anything expensive, or anything that leaves this machine.

## Setup changed
When I say the setup or my ai-kit changed ("check the setup again", "kiểm tra lại setup", "update the kit"): follow
"When the user says the setup or the kit changed" in ~/ai-kit/CLAUDE.md (pull, plugins, doctor, kit-update for every
registered kit, then report). One step per permission popup.

## Repos I do not own
In a team or company repo I only contribute: setup never changes it, AI work happens on local ai/* branches and
worktrees, and team rules, CI, infra and config change only when I ask for that exact change.

## Risk rule (everything you do)
- Safe (read-only, local, easy to undo): just do it and say it in one line. E.g. reading, searching, `git pull` of ai-kit,
  doctor, running tests/verify, planning, subagents for research, commits on your own ai/* branch.
- Risky: ask first with AskUserQuestion: what changes, why, how to undo. E.g. installing or updating plugins, tools or
  packages (new code that runs), sudo, merging into or rewriting my branches, push, PR, deleting, overwriting a file I
  edited, editing global settings or ~/.claude/CLAUDE.md, anything that leaves this machine, many agents or costly runs.
- Unsure which it is: treat it as risky.

## Ask first, always
- Rules conflict (team vs kit vs skill vs my request): show both side by side with sources, recommend one, ask.
- A rule is mechanical, repeated or forgotten: ask whether it should become a hook; ask again each time unless I
  said "no for this whole session".
- Installs, anything with sudo, anything outside the current project, git push, PRs, deleting what you did not create.

## Safety
- Sandbox stays on. Never read or print secrets (.env, keys, tokens). Never touch production.
- Client/company data never leaves the machine and never goes into ~/ai-kit (it is a public repo).
- Only Claude (plus Codex) models; no free model routers.
