# AI kit: what each file does (for the AI's self-review)

Kit v2 (2026-10-22). Everything here is private to one developer: listed in .git/info/exclude, never committed.

```
AGENTS.md                     shared rules for Claude and Codex (core + project section + active packs)
CLAUDE.local.md               Claude-only: how to talk, grill, git flow, onboarding
.claude/settings.local.json   permissions (ask before push/merge/PR), hooks below, harness = mattpocock
.ai/SKILLS.md                 skill map + how to propose new skills
.ai/packs.conf                PACKS=(...) active stack packs
.ai/packs/<name>/             RULES.md, antipatterns.rules.sh, verify.conf.example
.ai/verify.sh + verify.conf   the gate: --fast (seconds) and full (tests, build)
.ai/check_antipatterns.sh     rule-coded greps on CHANGED files only (old code does not block new work)
.ai/hooks/guard-git.sh        PreToolUse: commit only on ai/*, never push ai/*, never force-push
.ai/hooks/after-edit.sh       PostToolUse: team's pre-commit hooks on the edited file
.ai/hooks/stop-gate.sh        Stop: verify --fast in AI worktrees with uncommitted changes
.ai/git-hooks/pre-push        copy to .git/hooks/pre-push: ai/* never leaves the machine
.ai/bin/newsession            ai/<agent>/<date>-<name> branch + worktree in .worktrees/
.ai/bin/dispatch              Codex runs a ticket (role coder|tester) in a fresh context + worktree; script checks and commits
.ai/roles/                    prompts for the tester and coder roles (fresh contexts)
.ai/bin/mergesession          squash an ai/* branch into the user's branch (one clean commit)
.ai/bin/gate                  full verify + Codex adversarial review -> VERDICT PASS/BLOCK
.ai/tickets/, .ai/docs/       tickets, spec, glossary, ADRs (private, not the team's docs/)
.ai/logs/                     Codex outputs and review reports
```

## Onboarding: first session in a new project (and again whenever the user says "review the kit")
Do this with the user, asking with AskUserQuestion at each decision. Change nothing in tracked team files.
1. Read the project: README, CLAUDE.md / AGENTS.md of the team, docs/, manifests (pyproject, package.json),
   lint config (.pre-commit-config.yaml, eslint, ruff), CI files, test layout, how it runs (docker, bench, npm).
2. Detect the stack and propose packs for `.ai/packs.conf` (any stack works; see `.ai/packs/README.md`). No pack fits? Propose a new pack folder
   (RULES.md + antipatterns.rules.sh + verify.conf.example) built from the project's real conventions.
3. Compare kit rules with the team's rules and real code. List conflicts and rules that do not match; ask which to keep.
   The team's rules always win. Fill the "Project" section and TODOs in AGENTS.md.
4. Fill `.ai/verify.conf` with commands that really exist here. Ask how to run tests (docker or native, site name).
   Run `bash .ai/verify.sh` until green on the current code, or tell the user exactly which part cannot run and why.
5. Check `.ai/SKILLS.md` against what is installed and what this stack needs. Propose missing ones (official only).
6. Check the safety basics: private files excluded (`git status` shows none of them), pre-push hook in place,
   remote branch names, the user's default base branch. Ask for anything unclear.
7. Show the user a short summary of what changed in the kit files, then delete step list "First session" from CLAUDE.local.md.

## Freshness check (onboarding, "review the kit", /retro)
Look only at official sources, then propose changes to the user with AskUserQuestion (the user decides):
- Claude Code: the CHANGELOG and docs (code.claude.com/docs), `/plugin` for updates in claude-plugins-official.
- Codex: github.com/openai/codex releases, openai/codex-plugin-cc releases.
- The project's stack: release notes of its framework and main libraries at the versions in its manifests
  (e.g. github.com/frappe/frappe and erpnext releases, Vue/Vuetify changelogs); deprecations that touch our code.
- Installed skills: their source repos (new versions, new official skills from the same vendor).
For each finding: what changed, link, does it affect us, what we would change, effort and risk. Skip anything that does not affect us.
