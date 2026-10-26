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
3. Company or client machine: confirm with the user which AI tools the company allows (Claude, Codex, others) and which accounts.

## Phase 1: system packages (sudo) — MANIFEST C1
Install only what doctor reports missing. Afterwards `sudo apt-mark manual bubblewrap socat` so autoremove never drops the sandbox.

## Phase 2: user tools — MANIFEST C2
In table order (Node before npm tools, pipx before uv). Resolve pins, write them back to MANIFEST.md.
Logins are the user's: `claude` (first run), `codex login`, `gh auth login`. Tell the user when each is needed.

## Phase 3: core plugins — MANIFEST C3
`claude plugin marketplace add …` / `claude plugin install …@… ` one by one, including this repo's own marketplace
(`claude plugin marketplace add inujustin/ai-kit` from GitHub, never a local folder path: the installed copy must not
depend on ~/ai-kit, which the user may delete; then `claude plugin install ai-kit-workflow@ai-kit` and
`claude plugin install ponytail@ai-kit`). ai-kit-workflow carries the kit's hooks for every project on this machine.
Remind the user to run `/codex:setup` and `/claude-hud:setup` in a new Claude session.
Nothing stack-specific here: language servers, framework skills and packs are installed in Phase 5, per project.

## Phase 4: git identity, global rules and settings — MANIFEST C4
- Global rules: `bash bin/global-rules --diff`, show it, ask, then `bash bin/global-rules --apply`. It keeps the kit's
  rules as one marked block in `~/.claude/CLAUDE.md` (added on a new machine, replaced in place later, backup each
  time); the user's own lines stay as they are. Never put one project's rules in there. This carries the user's way of working to every machine.
- `env` in `~/.claude/settings.json`: `PONYTAIL_DEFAULT_MODE=lite` (ponytail builds what was asked and only names smaller options).
- context7: the user logs in once (the plugin's authenticate step opens a link); the AI cannot do it for them.
- Identity per folder: copy `machine/gitconfig-identity.template` to `~/.gitconfig-<name>` with the values the user gives
  (name, email and, when gh has several accounts, which GitHub account that folder uses for git and gh),
  and add the `includeIf` block from `machine/gitconfig-snippet.txt` to `~/.gitconfig` (show the diff first).
- Merge (never overwrite) the settings listed in MANIFEST C4 into `~/.claude/settings.json`; show the diff, ask.
- Open the global permissions: `bash bin/global-settings --diff`, then `--apply` (auto mode, broad allow rules, sandbox on,
  every registered repo and kit as an additional directory; deny rules kept). Global is loose so long runs never stop at
  a popup; the strict part is each project's kit (plugin hooks + mode.conf). Re-run after every new kit.
- AI tools and accounts (set up everything from the start, wherever the kit goes): detect the CLIs on this machine
  (`bash bin/doctor`: claude, codex, agy, gemini), then ask in one popup which ones the user uses here, how many
  accounts each, their plan (pro, max5, max20, plus, team, free) and purpose (company, startup, ...). Record the normal
  login with `bash bin/account add <tool> default <purpose> <plan>`. For each extra one: `bash bin/account add <tool> <name> <purpose> <plan>`,
  then give the user its one login line. Ask whether Codex may switch accounts by itself on quota (ROTATE=auto in
  ~/.config/ai-kit/accounts.conf; default ask). Say once: several accounts of one provider to get more quota may break
  its terms; the user decides. Later "I added an account" = the same steps for that one.
- Starting profile for new projects: ask the user's usual BUDGET / BRANCHES / REMOTE / ACCOUNT_GROUP and write them
  to ~/.config/ai-kit/profile-defaults.conf (KEY=value); kit-new copies them, the onboarding still asks.
- Lead launcher: tell the user that `bash $KIT/.ai/bin/ai [account|purpose]` starts the lead session; when it ends,
  `c` continues on the next account of the same tool, `n` starts fresh from handoff.md (offer a shell alias, ask).

## Phase 5: project kit (per project; the kit stays OUTSIDE the repo)
For each repo the user works on ("setup the kit for this project"):
1. Ask where to keep this project's kit (the user decides; e.g. a sibling folder or ~/kits/<repo>).
2. `bash ~/ai-kit/bin/kit-new <repo> <kit-folder>`: copies `project/` there, registers repo → kit in
   ~/.config/ai-kit/projects.tsv, lets Claude use the folder (additionalDirectories), adds
   graphify output names to .git/info/exclude. Nothing goes into the repo's files; `git status` stays clean.
3. Detect the stack (manifests, lock files, framework files). Install only its rows from MANIFEST "Per stack"
   (LSP plugin + server, official framework skills). No matching row: follow "Other" and `project/.ai/packs/README.md`.
4. Tell the user to open a NEW `claude` session in the repo: the plugin loads the kit and the onboarding in
   `$KIT/.ai/KIT.md` starts (repo rules, packs, verify, commit style, rule → hook scan).

## Phase 6: done
`bash bin/doctor` again. Report in a short table: installed (with versions), skipped (why), what the user still has to do
(logins, `/codex:setup`, `/claude-hud:setup`, privacy toggles). Ask whether to merge any kit changes (pins) into main.
