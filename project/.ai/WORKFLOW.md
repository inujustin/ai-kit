# Workflow: roles, separate contexts, git, push/PR

Read this when you dispatch work, review, commit, merge, push or open a PR. Hard limits are enforced by hooks
(plugin ai-kit-workflow guard-git, guard-repo, guard-outside); this file explains the flow around them.
Nothing here is one fixed way of working: each project has a work profile (`.ai/mode.conf`: BUDGET, BRANCHES, REMOTE,
TEST_POLICY) that the user picks at onboarding, and the AI asks again whenever the work changes shape.

## Roles: separate contexts, three by default (the user's rule)
Nobody checks its own work. Default team = planner, developer, reviewer; add a tester only when the work is risky and
`TEST_POLICY=tests` (mode.conf).
- Claude = lead and planner: grill, spec, tickets, dispatch, integrate, explain. Do not write production code or tests
  yourself: every change goes to a developer context.
- Developer = Codex (`dispatch <ticket>`), or a Claude subagent for a tiny change. Both edit the repo directly on the
  current branch, one ticket at a time; each passed ticket = one commit there.
- Tests are the user's call, asked often (TEST_POLICY in mode.conf, default ask): at onboarding, at the first code task of
  every session, and for every ticket. Give the facts from `bash $KIT/.ai/bin/test-scan`: the repo has tests → recommend
  writing them for logic changes; no tests → recommend skipping with "Manual checks". Record the answer in the ticket
  (`Tests: write | skip`). Tester (only for `Tests: write`) = a separate context writing tests from the ticket
  (`dispatch <ticket> tester`; dispatch refuses otherwise). `Tests: skip`: the user runs the Manual checks, the reviewer confirms.
- Reviewer = a clean context that did not write the code: `gate` (Codex) plus your own read of the diff.
- Executors are whatever this machine has (`bin/doctor` lists claude, codex, agy, gemini) on the accounts in
  `~/ai-kit/bin/account list`, limited by the project's PROVIDERS. See "Providers" and "Accounts and sessions" below.

## Sizing the team: BUDGET decides, and you ask
Saving is not always the goal: a startup project may get far more money, disk and quota than a small company task.
Start from BUDGET in mode.conf (lean / normal / max), then choose tickets, model, effort and agents from the size and
risk of the task, the context left and the quota left (claude-hud, `/usage`). Ask the user with AskUserQuestion
(options with cost/time, recommended first) before: more agents than BUDGET suggests, a long or overnight run, a
stronger model, or anything that uses a lot of disk. Never copy or clone the project "to be safe": that wastes disk
and drifts from the real code. Say in one line what you chose and what it costs.

## Dispatch
- Codex = executor for tickets: `bash $KIT/.ai/bin/dispatch $KIT/.ai/tickets/<id>.md` as a background Bash command.
  It works in the repo on the current branch; a lock makes tickets of one repo run one after the other. PASS = one
  commit; FAIL = changes left uncommitted for you to fix or show; QUOTA = ask the user (see Accounts).
  When one finishes, read `.ai/logs/<id>-<role>.md` and the commit and tell the user in a few lines whether it meets
  the acceptance items. Parallel work happens across projects (one kit each), or as read-only work (research,
  review subagents) inside one project.
- Codex = reviewer before a merge or PR: `bash $KIT/.ai/bin/gate <base>`. Summarise, do not paste.
- AI files (specs, glossary, ADRs, tickets) live in `.ai/docs/` and `.ai/tickets/`, never in the team's docs/.

## Separate contexts (no agent grades its own homework)
- Risky logic (money, tax, permissions, document states, APIs, data changes, calculations):
  1. tester: `bash $KIT/.ai/bin/dispatch <ticket> tester` writes failing tests from the ticket only.
  2. Review those tests with the user. If they are wrong, fix the ticket, not the tests.
  3. coder: `bash $KIT/.ai/bin/dispatch <ticket>` runs on top of the tester's commit and may not touch those tests (checked).
  4. reviewer: `bash $KIT/.ai/bin/gate` plus your own review of the diff.
- Small work (UI text, layout, rename, config) still goes developer → reviewer in separate contexts; only the tester
  step may be "no test needed". Unsure whether it is risky? Ask.
- Your own code is reviewed by `/codex:review` or `gate`, never only by you. Wide searches: an Explore subagent.
- You orchestrate without being asked: tickets go to separate contexts in a sensible order; the user sees results and
  decisions, not the dispatching.

## Branches: flexible, asked
Sometimes the user works on one branch, sometimes several in turn, sometimes several at once. Ask at the start of a
task that touches branches (the prompt hook reminds you): which branch(es), may the AI create and switch local
branches by itself and with which names (BRANCHES=auto + AUTO_BRANCH_ERE, e.g. for an overnight run agreed in a grill).
Typical styles, all set per project and per stage (ask; never assume one):
  - company work: mostly local, one branch at a time, no new branches without asking (BRANCHES=ask).
  - a long run agreed in a grill: the AI creates and switches the agreed branch names itself (BRANCHES=auto).
  - projects that want many branches: the AI plans them in a grill, then works them one after another in the same
    checkout, every branch kept as a clean story of small commits.
- Work directly in the one checkout. Never a worktree, clone or copy of the project (guard-git refuses them).
- New feature in a request while BRANCHES=auto: finish the current step and commit it, then create the new branch
  from the base (`git switch -c feat/<name> <base>`, base = develop/main or `branch.<b>.aibase`, never from the
  unfinished feature), say "now on feat/<name> (from <base>)" in one line and go on. One feature per branch, so
  every branch reads as its own clean story. BRANCHES=ask: the same, after a popup.
- Like a dev team: go back to an older branch to fix or finish it (commit first, switch, say so), and tidy up merged
  branches with `git branch -d` (git refuses unmerged ones). BRANCHES=auto does both by itself for branch names
  matching AUTO_BRANCH_ERE; `-D` (unmerged) and anything outside the pattern always asks. List what you deleted in
  the end-of-run report.
- Before switching: commit the finished step (or ask what to do with the unfinished one); never switch with a dirty
  tree in silence. Say in one line "now on <branch>". guard-git shows a popup unless BRANCHES=auto allows it.
- Several branches in one run: one task list (`.ai/run/tasks.json`), each task names its branch; switch, work,
  commit, switch back. Never mix two branches' changes in one commit.
- Never commit on protected branches (mode.conf). Never `reset --hard`, `clean`, rebase or delete work you did not
  create; guard-git asks for each of those anyway.

## Plans and tickets stay local
Plans: `~/.claude/plans/` (this machine only). Tickets and AI docs: `$KIT/.ai/`. Never commit or push them; only each
ticket's code reaches the repo, as commits on the branch. guard-git blocks staged kit, ticket or plan files.

## Commits: small steps a reviewer can follow
- One logical step per commit, in an order that reads naturally (preparation/refactor → behaviour, one rule or screen
  at a time → tests with the code they cover → docs). Never one big commit; give the SHA after each.
- Subject = the behaviour a user or teammate can observe, in the project's commit style (`.ai/commit-style.conf`,
  checked by guard-git): good "feat(transport): a job can't be completed before its day", bad "update transport.py".
  Body: why, and anything a reviewer must know.
- If the team's convention, a lint config, a skill's commit rules and this kit disagree, that is a rule conflict: ask
  which wins, then update the conf.

## Remote: REMOTE in mode.conf, always careful
Push is the most careful step of all. Before every push, even an allowed one: `git log --oneline <upstream>..<branch>`
and `git diff --stat` of what leaves, verify passes, no secret or client data (guard-git refuses pushes whose commits
hold .env, keys, dumps or backups), the right remote and branch. In the popup say exactly what goes where.
Local work can be freer; anything that reaches a server is asked carefully. REMOTE=ask: every push/pull/fetch/remote/gh
shows a popup. REMOTE=feature: pushing the feature branch passes, the rest asks. REMOTE=never: give the user one `!` line.
Per stage: when the user says "push by yourself" for a run, `touch $KIT/.ai/run/allow-push` (REMOTE=feature until
the run ends or 24 h pass; auto-continue removes it). Said nothing: commit only and list what is waiting to be pushed
in the end-of-run report; the user pushes later. Detect when the situation changes (first push of a branch, a new
remote, a PR, a release) and ask whether the level still fits.

## Careful, never sloppy
Automatic never means unchecked. Every automatic value or run starts from a popup that explained it and got a yes;
note the date in mode.conf. During the work: verify each step, small commits, stop and ask on anything unexpected.
At the end: the report (branches, commits, checks, pushed or local, decisions left), then AskUserQuestion for those.
- Push and PR, step by step, each with the user's OK: show `git status` + `git log <base>..HEAD` → `bash $KIT/.ai/bin/gate <base>`
  PASS → `git push -u origin <branch>` → show PR title and body → `gh pr create`.
  Never force-push, never push straight to a protected branch (guard-git refuses both).

## Providers: Claude + Codex first, free models only for tiny tasks
- PROVIDERS in mode.conf lists who may work on this project (at most 4). Asked at onboarding; when the user mentions a
  new AI or account ("tôi thêm account", "dùng thêm gemini"), ask whether to add it to this project and record it.
- Roles: Claude = lead, planner, reviewer. Codex = developer and second reviewer. agy / Gemini CLI (free, fast to run
  out, weaker code) = only tickets marked `Size: tiny` (rename, text, comment, one-file format, a few config lines):
  `dispatch <ticket> tiny`. Their result is never committed unreviewed: read the diff, fix or drop extras, commit.
- Who works now and the rotation order: `bash ~/ai-kit/bin/account plan [purpose]` (counts usable accounts and plans).
- Out of quota, in this order: next account of the SAME tool → fallback (ask first): no Codex left = a Claude
  subagent develops in its own context until Codex resets, reviewer stays separate; no Claude left = handoff, wait for
  reset (or Codex as the brain via `bin/ai --brain codex`, ask) → wait for reset. Tiny tasks fall back to Codex.

## Many projects on one machine: one team per project
- Each project = its own kit, its own lead session, its own memory (tickets, run, handoff). Never read, copy or mix
  another project's code, notes or rules; company and startup work stay apart.
- Machine-wide (global): `~/.claude/CLAUDE.md` rules, plugins/hooks, skills, accounts, `~/.config/ai-kit/
  profile-defaults.conf` (starting values for new kits), and `python3 ~/ai-kit/bin/projects` (read-only table of
  every kit: branch, run state, budget, priority, account group). Packs and practices stay per project; a lesson that
  helps every project is promoted by the user through ~/ai-kit.
- Accounts: ACCOUNT_GROUP in mode.conf (asked at onboarding, empty = ask each session, may change any time).
- Priority: PRIORITY=auto means you decide from `bin/projects` and say why in one line; when quota is short, say which
  project should yield and ask. While several run, at most once a day check official sources (Anthropic, OpenAI docs on
  usage and rate limits, long agent runs) and log news in PRACTICES.md; general words only, never project details.

## Accounts and sessions: few sessions, nothing lost
- One lead session per project (one terminal tab each; no extra ADE app needed), started with
  `bash ~/ai-kit/bin/ai [account|purpose]` (default: the project's ACCOUNT_GROUP) (Codex as the brain:
  `--brain codex`). Everything else runs in the background from it (dispatch, subagents, auto-continue).
- Accounts: `bash ~/ai-kit/bin/account list|add|next|out`. Each account has a purpose the user names (company,
  startup, ...); use the one that fits the project. A tool only switches to another account of the SAME tool.
- Out of quota: progress is always in `.ai/run/` and `handoff.md`. Claude: the user ends the session and picks `c` in
  `ai` (same conversation, next Claude account). Codex in dispatch: `ROTATE=auto` in ~/.config/ai-kit/accounts.conf
  retries on the next Codex account by itself; otherwise dispatch prints QUOTA and you ask the user.
- Context full or new topic: write handoff.md, ask the user to renew (`/clear`, or `/exit` + `n` in `ai`); the old
  chat stays in `claude --resume` / `codex resume`.
- New account on this machine: the user says so; run `account add` and give the one login line they must type.
