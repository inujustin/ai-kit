# Workflow: roles, separate contexts, git, push/PR

Read this when you dispatch work, review, commit, merge, push or open a PR. Hard limits are enforced by hooks
(plugin ai-kit-workflow guard-git, `.git/hooks/pre-push`); this file explains the flow around them.

## Roles
- Claude = lead: grill, spec, tickets, dispatch, integrate, review, explain. Do small fixes yourself.
- Codex = executor for clear tickets bigger than ~30 lines, or several independent ones:
  `bash $KIT/.ai/bin/dispatch $KIT/.ai/tickets/<id>.md` as a background Bash command; run in parallel only if their "Owns" files
  do not overlap. When one finishes, read `.ai/logs/<id>.md` and its diff and tell the user in a few lines whether it
  meets the acceptance items.
- Codex = reviewer before a merge or PR: `bash $KIT/.ai/bin/gate <base>`. Summarise, do not paste.
- AI files (specs, glossary, ADRs, tickets) live in `.ai/docs/` and `.ai/tickets/`, never in the team's docs/.

## Separate contexts (no agent grades its own homework)
- Risky logic (money, tax, permissions, document states, APIs, data changes, calculations):
  1. tester: `bash $KIT/.ai/bin/dispatch <ticket> tester` writes failing tests from the ticket only.
  2. Review those tests with the user. If they are wrong, fix the ticket, not the tests.
  3. coder: `bash $KIT/.ai/bin/dispatch <ticket>` starts from the tests branch and may not touch tests (the script checks).
  4. reviewer: `bash $KIT/.ai/bin/gate` plus your own review of the diff.
- Small work (UI text, layout, rename, config): one context is fine. Unsure whether it is risky? Ask.
- Your own code is reviewed by `/codex:review` or `gate`, never only by you. Wide searches: an Explore subagent.

## Git (local AI branches, clean history)
- Your work: `bash $KIT/.ai/bin/newsession claude <short-name>` → branch `ai/claude/<date>-<name>` in `$KIT/worktrees/`.
  1 request = 1 commit there; give the SHA. Commit messages end with `Co-Authored-By: Claude <noreply@anthropic.com>`.
- Commits only on ai/* branches (hook). ai/* branches never reach the remote (pre-push hook).
- When a piece of work is done and checked, ask whether to merge now (merge now / review first in lazygit or
  VS Code Git Graph / keep working). Default merge = a story (below). Squash with `bash $KIT/.ai/bin/mergesession <ai-branch> "<msg>"`
  only when the work really is one small change.
## Plans and tickets stay local
Plans: `~/.claude/plans/` (this machine only). Tickets and AI docs: `$KIT/.ai/`. Never commit or push them; only each
ticket's code reaches the repo (ai/* → story → review). guard-git blocks staged kit, ticket or plan files.

## Story commits (what reaches the user's branch and the remote)
The raw ai/* history (wip, retries) stays local. What lands on the user's branch is a story a reviewer can read top to bottom:
1. `bash $KIT/.ai/bin/story start <ai-branch>`: story branch + worktree from the user's branch; prints the changes to tell.
2. Plan the story first and show it to the user as a short list: one commit per logical step, in an order that reads
   naturally (preparation/refactor → behaviour, one rule or screen at a time → tests with the code they cover → docs).
   Each subject says the behaviour a user or teammate can observe, not the code touched
   (good: "feat(transport): a job can't be completed before its day"; bad: "update transport.py").
   Body: why, and anything a reviewer must know. Keep `Co-Authored-By: Claude <noreply@anthropic.com>`.
3. Build the commits in the story worktree: whole files with `git checkout <ai-branch> -- <paths>`, part of a file with
   `git diff <base> <ai-branch> -- <file>` edited down and applied with `git apply --cached`.
4. `bash $KIT/.ai/bin/story check`: end result must be identical to the ai/* branch, every commit passes `verify --fast`,
   every subject matches `.ai/commit-style.conf`. Fix and re-check until PASS.
5. Ask the user (show the story list), then `bash $KIT/.ai/bin/story finish` fast-forwards their branch. Undo before push:
   `git reset --hard ORIG_HEAD` on their branch.
Commit style: `.ai/commit-style.conf`. If the team's convention, a lint config, a skill's commit rules and this kit
disagree, that is a rule conflict: ask which wins, then update the conf.

- Push and PR, step by step, each with the user's OK: show `git status` + `git log <base>..HEAD` → `bash $KIT/.ai/bin/gate <base>`
  PASS → `git push -u origin <branch>` → show PR title and body → `gh pr create`.
  Never push ai/*, never force-push, never push straight to main/master/develop.
- Never `reset --hard` / `clean` work you did not create, rewrite the user's branches, add remotes, or bare `git stash`.
