# Workflow: roles, separate contexts, git, push/PR

Read this when you dispatch work, review, commit, merge, push or open a PR. Hard limits are enforced by hooks
(`.ai/hooks/guard-git.sh`, `.git/hooks/pre-push`); this file explains the flow around them.

## Roles
- Claude = lead: grill, spec, tickets, dispatch, integrate, review, explain. Do small fixes yourself.
- Codex = executor for clear tickets bigger than ~30 lines, or several independent ones:
  `bash .ai/bin/dispatch .ai/tickets/<id>.md` as a background Bash command; run in parallel only if their "Owns" files
  do not overlap. When one finishes, read `.ai/logs/<id>.md` and its diff and tell the user in a few lines whether it
  meets the acceptance items.
- Codex = reviewer before a merge or PR: `bash .ai/bin/gate <base>`. Summarise, do not paste.
- AI files (specs, glossary, ADRs, tickets) live in `.ai/docs/` and `.ai/tickets/`, never in the team's docs/.

## Separate contexts (no agent grades its own homework)
- Risky logic (money, tax, permissions, document states, APIs, data changes, calculations):
  1. tester: `bash .ai/bin/dispatch <ticket> tester` writes failing tests from the ticket only.
  2. Review those tests with the user. If they are wrong, fix the ticket, not the tests.
  3. coder: `bash .ai/bin/dispatch <ticket>` starts from the tests branch and may not touch tests (the script checks).
  4. reviewer: `bash .ai/bin/gate` plus your own review of the diff.
- Small work (UI text, layout, rename, config): one context is fine. Unsure whether it is risky? Ask.
- Your own code is reviewed by `/codex:review` or `gate`, never only by you. Wide searches: an Explore subagent.

## Git (local AI branches, clean history)
- Your work: `bash .ai/bin/newsession claude <short-name>` → branch `ai/claude/<date>-<name>` in `.worktrees/`.
  1 request = 1 commit there; give the SHA. Commit messages end with `Co-Authored-By: Claude <noreply@anthropic.com>`.
- Commits only on ai/* branches (hook). ai/* branches never reach the remote (pre-push hook).
- When a piece of work is done and checked, ask whether to merge now (merge now / review first in lazygit or
  VS Code Git Graph / keep working). Merge = `bash .ai/bin/mergesession <ai-branch> "<message>"` (squash, one clean commit).
- Push and PR, step by step, each with the user's OK: show `git status` + `git log <base>..HEAD` → `bash .ai/bin/gate <base>`
  PASS → `git push -u origin <branch>` → show PR title and body → `gh pr create`.
  Never push ai/*, never force-push, never push straight to main/master/develop.
- Never `reset --hard` / `clean` work you did not create, rewrite the user's branches, add remotes, or bare `git stash`.
