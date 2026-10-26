# AI kit: what each file does (for the AI's self-review)

Kit v3 (2026-10-23). The kit lives OUTSIDE the project repo, in a folder the user picks, registered in ~/.config/ai-kit/projects.tsv
(`bash ~/ai-kit/bin/kit-new <repo> <kit>`). Hooks come from the ai-kit-workflow plugin, not from files in the repo.
A kit never needs ~/ai-kit while it runs: its tools are in `$KIT/.ai/bin` (dispatch, gate, run, account, ai, projects),
its hooks come from the plugin installed from GitHub (a copy in ~/.claude/plugins), its registry is ~/.config/ai-kit.
~/ai-kit may be deleted; only setup and updates need a source, and setup clones it again from GitHub when missing.
Update from the source with `bash ~/ai-kit/bin/kit-update <kit>` (never overwrites your edits; lists them to review).

```
AGENTS.md                     shared rules for Claude and Codex (core + project section + active packs)
CLAUDE.local.md               Claude-only, kept short: how to talk, ask on conflicts, rule → hook, stay current
.ai/WORKFLOW.md               roles, Codex dispatch, separate contexts, git, push/PR (read when needed)
.ai/HOOKS.md                  rule → hook: signals, proactive scan, existing hooks, candidates log
.ai/PRACTICES.md              best practices the AI must notice and grill the user about; leads already checked
.ai/lib.sh                    sets KIT (this folder) and ROOT (the repo) for every script
.ai/hooks/<Event>/*.sh        this project's own hooks (run by the plugin for this project only)
.ai/SKILLS.md                 skill map + how to propose new skills
.ai/packs.conf                PACKS=(...) active stack packs
.ai/packs/<name>/             RULES.md, antipatterns.rules.sh, verify.conf.example
.ai/verify.sh + verify.conf   the gate: --fast (seconds) and full (tests, build)
.ai/check_antipatterns.sh     rule-coded greps on CHANGED files only (old code does not block new work)
(plugin ai-kit-workflow)      hooks: session-start (loads this kit + lists the repo's rule files), prompt-skills,
                              guard-git, after-edit (team pre-commit), guard-outside, guard-repo, guard-lead (one lead
                              session per project), stop-gate (verify --fast on uncommitted changes), context-watch, auto-continue
.ai/bin/dispatch              ROLE_DEV (Codex, or a fresh Claude session) runs a ticket (role coder|tester) in a fresh
                              context, in the repo on the current branch, one at a time; script checks and commits on PASS;
                              Codex out of quota -> next Codex account if allowed, then a fresh Claude session (DEV_FALLBACK)
.ai/bin/fresh                 long run with a fresh lead session per task (`claude -p`, unattended, no popups)
.ai/run/costs.tsv             cost and tokens of every `claude -p` session (fresh, dispatch, gate); totals in bin/status
.ai/roles/                    prompts for the tester, coder, reviewer and tiny roles (fresh contexts)
.ai/commit-style.conf         commit subject rules (checked by guard-git), set at onboarding
.ai/mode.conf                 work profile: BUDGET, BRANCHES, REMOTE, PROTECTED_BRANCHES, TEST_POLICY (asked, re-asked)
.ai/bin/run, .ai/LONGRUN.md   long runs: tasks.json (a task may name its branch), progress.md, two-attempt limit, auto run
$KIT/.ai/bin/projects         (machine) read-only table of every project kit, most urgent first
$KIT/.ai/bin/account, bin/ai  (machine) accounts per tool + purpose; one-terminal lead launcher (quota -> next account of
                              the same tool, context full -> new session from handoff.md), Claude or Codex as the brain
.ai/footprints/               HTML catch-up pages per big change (TEMPLATE.html, INDEX.md); never in the repo
.ai/handoff.md                session snapshot for the next session (context-watch asks for it near ~70%)
.ai/bin/gate                  full verify + adversarial review by ROLE_REVIEW (Codex; Claude when Codex is missing or out
                              of quota) in a read-only fresh context -> VERDICT PASS/BLOCK
.ai/tickets/, .ai/docs/       tickets, spec, glossary, ADRs (private, not the team's docs/)
.ai/logs/                     Codex outputs and review reports
```

## Onboarding: first session in a new project (and again whenever the user says "review the kit")
Do this with the user, asking with AskUserQuestion at each decision. READ ONLY on the repo: change nothing in it, run no
formatters or fixers on it (the guard-repo hook blocks this); everything you write goes into the kit.
1. Read the project: README, CLAUDE.md / AGENTS.md of the team, docs/, manifests (pyproject, package.json),
   lint config (.pre-commit-config.yaml, eslint, ruff), CI files, test layout, how it runs (docker, bench, npm).
2. Detect the stack and propose packs for `.ai/packs.conf` (any stack works; see `.ai/packs/README.md`). No pack fits? Propose a new pack folder
   (RULES.md + antipatterns.rules.sh + verify.conf.example) built from the project's real conventions.
3. Compare kit rules with the team's rules and real code. List conflicts and rules that do not match; ask which to keep.
   The team's rules always win. Fill the "Project" section and TODOs in AGENTS.md.
4. Fill `.ai/verify.conf` with commands that really exist here. Ask how to run tests (docker or native, site name).
   Ask before running `bash $KIT/.ai/verify.sh --all`: it runs in place and reports any file a check rewrote (restore
   those with `git checkout -- <file>` if the user agrees; they were not yours to change). Red on the
   current code is the team's state, not yours to fix: report it and ask; adjust only the kit's verify.conf.
5. Check `.ai/SKILLS.md` against what is installed and what this stack needs. Propose missing ones (official only).
6. Check the safety basics: private files excluded (`git status` shows none of them), remote names, the user's default
   base branch (`git config branch.<b>.aibase` if it is not develop/main/master). Ask for anything unclear.
6c. Tests: run `bash $KIT/.ai/bin/test-scan`, show the result, and ask the user TEST_POLICY (ask / tests / manual);
   write it to mode.conf. Whatever they pick, the AI re-asks at session start and per ticket.
6a. Ownership, grilled hard (it decides what may be committed): did the user join this repo or create it (REPO_ROLE)?
   Which AI files does the repo already have (team rules win)? Kit under version control (KIT_GIT none / local /
   remote private repo next to the code repo; `git init` in the kit for local)? Ask again if signs change (the user
   says they own it, a new empty repo, no other committers).
   REPO_ROLE=owner: say plainly that the kit alone is not 24/7 automation yet and offer PRACTICES.md BP-11 (cloud
   agents, CI gate and auto-merge, preview deploys, nightly jobs, errors to tickets), one item at a time.
6b. Work profile (mode.conf), one AskUserQuestion with up to 4 questions, each value explained in plain words:
   BUDGET (lean / normal / max: is this a small company task or something the user invests in?), BRANCHES (ask /
   auto + which names), REMOTE (ask / feature / never; per run: allow-push), PROTECTED_BRANCHES of this repo, ACCOUNT_GROUP (which accounts,
   `$KIT/.ai/bin/account list`), ROLE_LEAD/DEV/REVIEW/TINY (who does what, proposed from `$KIT/.ai/bin/account plan`:
   which tools, accounts and plans this machine has; e.g. Claude subagents develop when Codex is small), PROVIDERS (which AIs: Claude + Codex, plus agy/Gemini for tiny tasks? max 4), PRIORITY (auto / high / normal / low against the other projects, `$KIT/.ai/bin/projects`). Say these are re-asked whenever the work changes shape.
7. Commit style: read the team's last ~50 commit subjects by other people (`git log --format=%s --author=...`), commitlint,
   .gitmessage, CONTRIBUTING, and the commit rules of installed skills. Propose `.ai/commit-style.conf` from what the team
   really does; if sources disagree with each other or with the kit default, ask which wins (show examples of each).
8. Rule → hook scan (`.ai/HOOKS.md` "Proactive scan"): one multiSelect question with every candidate you found.
8b. Best practices (`.ai/PRACTICES.md`): one multiSelect question with the proposed ones that fit this project.
9. Show the user a short summary of what changed in the kit files, then delete step list "First session" from CLAUDE.local.md.

## Freshness check (onboarding, "review the kit", weekly look-back)
Look only at official sources, then propose changes to the user with AskUserQuestion (the user decides):
- Claude Code: the CHANGELOG and docs (code.claude.com/docs), `/plugin` for updates in claude-plugins-official.
- Codex: github.com/openai/codex releases, openai/codex-plugin-cc releases.
- The project's stack: release notes of its framework and main libraries at the versions in its manifests
  (e.g. github.com/frappe/frappe and erpnext releases, Vue/Vuetify changelogs); deprecations that touch our code.
- Installed skills: their source repos (new versions, new official skills from the same vendor).
- Pinned plugins in the ai-kit marketplace: newer commits at least 14 days old; read their hook diff before proposing.
- Run `/doctor` in Claude Code: it reports oversized skills and CLAUDE.md files (Anthropic: keep CLAUDE.md light,
  move detail into files read on demand). Propose trims and rule → hook moves from what it finds.
- Run `/doctor prompt-audit` (Claude Code 2.1.283+; alias `/checkup prompt-audit`), read-only, at the weekly look-back
  and "review the kit": it reports stale rules, stale paths and commands, and instructions that contradict each other
  across CLAUDE.md, AGENTS.md, skills, agents and commands. Each finding becomes one proposed fix, asked one by one with
  AskUserQuestion; back up the file before changing it. Scanning many skills costs tokens: ask before running it on
  everything (default: this project's CLAUDE.md, the kit's AGENTS.md and CLAUDE.local.md only).
For each finding: what changed, link, does it affect us, what we would change, effort and risk. Skip anything that does not affect us.
