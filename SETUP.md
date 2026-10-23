# SETUP: playbook for the AI ("setup everything")

Talk to the user in their language. Ask with AskUserQuestion at each decision. One install per tool call.

## sudo
- Never ask the user to type a password into chat, never store it, never pass it on a command line.
- Sandboxed commands cannot use sudo. Run each sudo command as its own tool call outside the sandbox, after
  saying in one line what it changes; the permission popup is the user's approval.
- Desktop or WSLg available (`$DISPLAY` or `$WAYLAND_DISPLAY` set) and zenity installed:
  `SUDO_ASKPASS="$HOME/ai-kit/bin/askpass" sudo -A <command>` → a password window pops up for the user.
- No desktop (SSH, server VM) or no zenity yet: give the user the exact command to run in their own terminal
  (or `! <command>` in the Claude prompt), wait, then run `bash bin/doctor` to confirm.

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
(`claude plugin marketplace add inujustin/ai-kit`, then `claude plugin install ponytail@ai-kit`).
Remind the user to run `/codex:setup` and `/claude-hud:setup` in a new Claude session.
Nothing stack-specific here: language servers, framework skills and packs are installed in Phase 5, per project.

## Phase 4: git identity, global rules and settings — MANIFEST C4
- Global rules: merge `machine/CLAUDE.global.md` into `~/.claude/CLAUDE.md` (append if the marker line `ai-kit global rules`
  is missing; never delete the user's own lines). Show the diff, ask. This carries the user's way of working to every machine.
- context7: the user logs in once (the plugin's authenticate step opens a link); the AI cannot do it for them.
- Screenshots: create `~/shots/` (outside every repo) and allow Claude to read it only: add
  `"Edit(~/shots/**)"`, `"Write(~/shots/**)"` to `permissions.deny` in `~/.claude/settings.json` (show the diff, ask).
  The user pastes screenshots by opening `~/shots/paste.md` in VS Code and pressing Ctrl+V (VS Code saves the image there).
- Identity per folder: copy `machine/gitconfig-identity.template` to `~/.gitconfig-<name>` with the values the user gives,
  and add the `includeIf` block from `machine/gitconfig-snippet.txt` to `~/.gitconfig` (show the diff first).
- Merge (never overwrite) the settings listed in MANIFEST C4 into `~/.claude/settings.json`; show the diff, ask.

## Phase 5: project kit
For the folder the user names (must be a git repo):
1. `cp -r --update=none ~/ai-kit/project/. <dir>/` (never overwrites team files).
2. Append `~/ai-kit/project-exclude.txt` to `<dir>/.git/info/exclude`.
3. `cp ~/ai-kit/project/.ai/git-hooks/pre-push <dir>/.git/hooks/pre-push` if none exists; otherwise show both and ask.
4. In `<dir>`: `git status` must show none of the kit files.
5. Detect the project's stack (manifests, lock files, framework files). Install only its rows from MANIFEST "Per stack"
   (LSP plugin + server, official framework skills). No matching row: follow "Other" and `project/.ai/packs/README.md`.
6. Tell the user to open `claude` in `<dir>`; the onboarding in `.ai/KIT.md` starts there (packs, verify, team rules).

## Phase 6: done
`bash bin/doctor` again. Report in a short table: installed (with versions), skipped (why), what the user still has to do
(logins, `/codex:setup`, `/claude-hud:setup`, privacy toggles). Ask whether to merge any kit changes (pins) into main.
