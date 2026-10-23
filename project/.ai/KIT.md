# AI kit: what each file does (for the AI's self-review)

Kit v3 (2026-10-23). Everything here is private to one developer: listed in .git/info/exclude, never committed.

```
AGENTS.md                     shared rules for Claude and Codex (core + project section + active packs)
CLAUDE.local.md               Claude-only, kept short: how to talk, ask on conflicts, rule → hook, stay current
.ai/WORKFLOW.md               roles, Codex dispatch, separate contexts, git, push/PR (read when needed)
.ai/HOOKS.md                  rule → hook: signals, proactive scan, existing hooks, candidates log
.claude/settings.local.json   permissions (ask before push/merge/PR), hooks below, harness = mattpocock
.ai/SKILLS.md                 skill map + how to propose new skills
.ai/packs.conf                PACKS=(...) active stack packs
.ai/packs/<name>/             RULES.md, antipatterns.rules.sh, verify.conf.example
.ai/verify.sh + verify.conf   the gate: --fast (seconds) and full (tests, build)
.ai/check_antipatterns.sh     rule-coded greps on CHANGED files only (old code does not block new work)
.ai/hooks/guard-git.sh        PreToolUse: commit only on ai/*, never push ai/*, never force-push
.ai/hooks/after-edit.sh       PostToolUse: team's pre-commit hooks on the edited file
.ai/hooks/stop-gate.sh        Stop: verify --fast in AI worktrees with uncommitted changes
.ai/hooks/session-start.sh    SessionStart: reminds Claude of ask-first rules and pending hook candidates
.ai/hooks/prompt-skills.sh    UserPromptSubmit: skill hints from keywords in every prompt (keep in sync with SKILLS.md)
.ai/git-hooks/pre-push        copy to .git/hooks/pre-push: ai/* never leaves the machine
.ai/bin/newsession            ai/<agent>/<date>-<name> branch + worktree in .worktrees/
.ai/bin/dispatch              Codex runs a ticket (role coder|tester) in a fresh context + worktree; script checks and commits
.ai/roles/                    prompts for the tester and coder roles (fresh contexts)
.ai/bin/story                 default merge: rebuild ai/* work as a clean story of commits; check (identical result,
                              verify per commit, commit style) then fast-forward the user's branch
.ai/commit-style.conf         commit subject rules for story check, set from the team's convention at onboarding
.ai/bin/mergesession          squash merge, only for one small change
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
7. Commit style: read the team's last ~50 commit subjects by other people (`git log --format=%s --author=...`), commitlint,
   .gitmessage, CONTRIBUTING, and the commit rules of installed skills. Propose `.ai/commit-style.conf` from what the team
   really does; if sources disagree with each other or with the kit default, ask which wins (show examples of each).
8. Rule → hook scan (`.ai/HOOKS.md` "Proactive scan"): one multiSelect question with every candidate you found.
9. Show the user a short summary of what changed in the kit files, then delete step list "First session" from CLAUDE.local.md.

## Freshness check (onboarding, "review the kit", /retro)
Look only at official sources, then propose changes to the user with AskUserQuestion (the user decides):
- Claude Code: the CHANGELOG and docs (code.claude.com/docs), `/plugin` for updates in claude-plugins-official.
- Codex: github.com/openai/codex releases, openai/codex-plugin-cc releases.
- The project's stack: release notes of its framework and main libraries at the versions in its manifests
  (e.g. github.com/frappe/frappe and erpnext releases, Vue/Vuetify changelogs); deprecations that touch our code.
- Installed skills: their source repos (new versions, new official skills from the same vendor).
- Pinned plugins in the ai-kit marketplace: newer commits at least 14 days old; read their hook diff before proposing.
- Run `/doctor` in Claude Code: it reports oversized skills and CLAUDE.md files (Anthropic: keep CLAUDE.md light,
  move detail into files read on demand). Propose trims and rule → hook moves from what it finds.
For each finding: what changed, link, does it affect us, what we would change, effort and risk. Skip anything that does not affect us.
