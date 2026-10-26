<!-- ai-kit global rules v2. Installed into ~/.claude/CLAUDE.md by bin/global-rules (merged, never overwriting the user's own lines). -->
Machine-wide rules shared by every project on this machine (one AI team per project; each project's own rules live
in its kit, never here). Where my own lines outside this block disagree (local ai/* branches, worktrees, newsession,
mergesession, asking a lot, "sandbox stays on no matter what"), this block is newer and wins.
# How to work with me (every project, every machine)

I give short, high-level prompts and keep my head for ideas and decisions. You remember the process, pick the tools,
and keep working. **Global is loose, the project kit is strict**: here you act; locks live only in each project's kit
(`$KIT/.ai/mode.conf` + the ai-kit-workflow hooks). Long and overnight jobs must never stop at a popup.

## Talk
- Reply in my language (Vietnamese by default), short and plain; keep technical terms.
- Ask only a decision that is truly mine and changes the result: ONE AskUserQuestion popup (max 4, recommended first),
  batched, during the work. Never re-ask or re-confirm what I already answered. Everything else: decide, say it in one
  line, keep going. "no grill" / "just do it" / "đừng hỏi" / I'm away = ask nothing, end with "Decisions I made".
- A question for me always goes through the question tool, never as a question inside a reply.
- Never ask me to type a command. Only what you truly cannot do (sudo, logins, a push your permissions block) comes
  as ONE copy-ready line with what it does.
- Commands: one simple command per Bash call, absolute paths, no `cd`, no `sleep`, no long chains, so allow rules match
  and nothing pops up.

## Never wait: many agents, in parallel
- Split work into independent tickets and run them at the same time: Codex tickets (`dispatch`) and Claude subagents in
  the background, Explore subagents for searches. While one agent codes or reviews, do the next independent ticket,
  footprints, tickets or the next plan. Waiting idle for another agent is a bug.
- Planner, developer and reviewer are separate contexts; nobody checks its own work.
- Parallel count, model and effort follow the project's BUDGET (lean / normal / max); within it, go wide by default and
  say the cost in one line. Only edits that touch the same files, or one branch checkout, are serialized.
- Show the team in chat: after each dispatch wave and whenever an agent finishes, a small markdown table
  (agent · ticket · status · branch; `bash $KIT/.ai/bin/status` in a kit). The statusline (claude-hud) shows running agents.

## Plans and footprints are kept
- Every plan that leaves plan mode is saved by the plan-record hook (`$KIT/.ai/plans/`, no kit:
  `~/.local/state/ai-kit/plans/<repo>/`). The footprint of that work links its plan; set the plan done/dropped at the end.
- A change big enough to need reading code gets a footprint (`$KIT/.ai/footprints`, WORKFLOW.md).

## Act on your own (standing permission, say what you did in one line)
- Only a question ("?", "là gì", "tại sao", "how"): answer only, cheaply.
- Never switch to plan mode by yourself. Plan mode only when I ask for a plan; otherwise plan in a few lines and do it.
- Skills, subagents, Codex tickets, reviews, tests, verify, small local commits, installing nothing: just do them.
- Accounts: out of quota = the next account of the SAME tool (`$KIT/.ai/bin/account next <tool>`), progress in the handoff.
- Many projects: one AI team per project, never mix their code or notes; you decide priority (`$KIT/.ai/bin/projects`).

## Setup: I only say it at a high level
"setup" / "kiểm tra setup lại" / "update the kit": do it all yourself (~/ai-kit/CLAUDE.md), report in a short table.
It also opens the global permissions (`bash ~/ai-kit/bin/global-settings --apply`; doctor checks they are open).

## Still asks (project kit) or never (everywhere)
- Strict per project, in the kit (not here): branches, remote, protected branches, repo hands-off, outside the
  workspace. A kit can be opened for a while: `run open <hours> "<why>"` (I pick the hours, default 8); it closes by
  itself when the time is up.
- Ask first everywhere: sudo, installs of new code (plugins, packages), push/PR when the project's REMOTE says ask,
  deleting what you did not create, anything that leaves this machine with project data.
- Never: read or print secrets (.env, keys, tokens), touch production, force-push, push to protected branches, client or
  company data into ~/ai-kit (public repo) or off the machine, free model routers or switchers. Sandbox stays on
  (it is wide: every registered repo and kit).
