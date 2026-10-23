# SETUP: playbook for the AI ("setup everything")

Talk to the user in their language. Ask with AskUserQuestion at each decision. One install per tool call.

## sudo
- Never ask the user to type a password into chat, never store it, never pass it on a command line.
- The AI never runs sudo. Give the user the exact command, one per step, with one plain line on what it changes and
  how to undo it; the user runs it in their own terminal. Wait, then run `bash bin/doctor` to confirm.

## Phase 0: look before touching
1. `bash bin/doctor` → show the user a short table: OK / missing / wrong version.
2. Ask: is this machine personal, company, or a client VM? Which git identity for which folders? Which project folder
   gets the project kit? Anything they do NOT want installed here?
3. Company or client machine: confirm with the user that the company allows Claude and Codex (and which accounts).

## Phase 1: system packages (sudo) — MANIFEST C1
Install only what doctor reports missing. Afterwards `sudo apt-mark manual bubblewrap socat` so autoremove never drops the sandbox.

## Phase 2: user tools — MANIFEST C2
In table order (Node before npm tools, pipx before uv). Resolve pins, write them back to MANIFEST.md.
Logins are the user's: `claude` (first run), `codex login`, `gh auth login`. Tell the user when each is needed.

## Phase 3: core plugins — MANIFEST C3
`claude plugin marketplace add …` / `claude plugin install …@… ` one by one, including this repo's own marketplace
(`claude plugin marketplace add inujustin/ai-kit`, then `claude plugin install ai-kit-workflow@ai-kit` and
`claude plugin install ponytail@ai-kit`). ai-kit-workflow carries the kit's hooks for every project on this machine.
Remind the user to run `/codex:setup` and `/claude-hud:setup` in a new Claude session.
Nothing stack-specific here: language servers, framework skills and packs are installed in Phase 5, per project.

## Phase 4: git identity, global rules and settings — MANIFEST C4
- Global rules: merge `machine/CLAUDE.global.md` into `~/.claude/CLAUDE.md` (append if the marker line `ai-kit global rules`
  is missing; never delete the user's own lines). Show the diff, ask. This carries the user's way of working to every machine.
- `env` in `~/.claude/settings.json`: `PONYTAIL_DEFAULT_MODE=lite` (ponytail builds what was asked and only names smaller options).
- context7: the user logs in once (the plugin's authenticate step opens a link); the AI cannot do it for them.
- Identity per folder: copy `machine/gitconfig-identity.template` to `~/.gitconfig-<name>` with the values the user gives,
  and add the `includeIf` block from `machine/gitconfig-snippet.txt` to `~/.gitconfig` (show the diff first).
- Merge (never overwrite) the settings listed in MANIFEST C4 into `~/.claude/settings.json`; show the diff, ask.

## Phase 5: project kit (per project; the kit stays OUTSIDE the repo)
For each repo the user works on ("setup the kit for this project"):
1. Ask where to keep this project's kit (the user decides; e.g. a sibling folder or ~/kits/<repo>).
2. `bash ~/ai-kit/bin/kit-new <repo> <kit-folder>`: copies `project/` there, registers repo → kit in
   ~/.config/ai-kit/projects.tsv, lets Claude use the folder (additionalDirectories), adds .git/hooks/pre-push and
   graphify output names to .git/info/exclude. Nothing goes into the repo's files; `git status` stays clean.
3. Detect the stack (manifests, lock files, framework files). Install only its rows from MANIFEST "Per stack"
   (LSP plugin + server, official framework skills). No matching row: follow "Other" and `project/.ai/packs/README.md`.
4. Tell the user to open a NEW `claude` session in the repo: the plugin loads the kit and the onboarding in
   `$KIT/.ai/KIT.md` starts (repo rules, packs, verify, commit style, rule → hook scan).

## Phase 6: done
`bash bin/doctor` again. Report in a short table: installed (with versions), skipped (why), what the user still has to do
(logins, `/codex:setup`, `/claude-hud:setup`, privacy toggles). Ask whether to merge any kit changes (pins) into main.
