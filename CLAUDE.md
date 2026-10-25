# ai-kit (personal, public repo github.com/inujustin/ai-kit)

This folder is the user's portable AI setup. It contains no client or company data and must never receive any.
Reply in the user's language (Vietnamese by default), short and plain. Grill with AskUserQuestion at each real decision.
Every permission popup and every question carries its own brief explanation in the user's language (what, what it
changes, why, remote or not, undo, which option); the user reads the popup, not the chat. One step per permission.
Claude + Codex first; other official CLIs (agy, Gemini CLI) only per project for tiny tasks. Never install free model
routers or switchers (omniroute, claude-code-router, cc-switch).

## When the user says "setup everything" / "cài hết" / "setup this machine"
Follow `SETUP.md` from the top. It installs the tools, plugins and skills in `MANIFEST.md`, sets the git identity,
then installs the project kit (`project/`) into the folder the user names and starts its onboarding.
- Run `bash bin/doctor` first and after each phase; it shows what is OK and what is missing.
- You may install everything in MANIFEST.md yourself, one command per tool call, so the user approves each one.
  Commands that need sudo: follow "sudo" in SETUP.md. Never store or echo the password.
- Pins: install exactly the version in MANIFEST.md. A row marked "resolve" means: pick the newest release that is
  at least 14 days old, from the official source, and write the version you used back into MANIFEST.md.
- Downloaded installers: save to a file, read it, then run it. Never `curl | sh`.
- Stop and ask when something is not in MANIFEST.md, when a source looks different from MANIFEST.md, or when a step fails twice.

## When the user says the setup or the kit changed ("I updated, check the setup", "kiểm tra lại setup", "update the kit")
Do the refresh yourself, one step per permission popup, then report in a short table.
Safe, just do and say it: `git pull` of ai-kit, `claude plugin marketplace update`, `bin/doctor`, reading diffs.
Risky, ask first (AskUserQuestion with what changes and how to undo): installing or updating any plugin, tool or package
(new code that will run), anything with sudo, `kit-update` (show what upstream changed first), keeping or overwriting a
file the user edited, deleting anything, editing ~/.claude/settings.json or ~/.claude/CLAUDE.md.
1. `git -C ~/ai-kit pull` (or the user's ai-kit source folder).
2. `claude plugin marketplace update ai-kit`, then install or update every plugin MANIFEST lists for this machine
   (`claude plugin install <name>@<marketplace>`; already installed → `claude plugin update <name>@<marketplace>`).
3. `bash ~/ai-kit/bin/global-rules --diff`: if it shows changes, show them and ask, then `--apply` (one marked block,
   shared by every project on the machine; the user's own lines are untouched).
4. `bash ~/ai-kit/bin/doctor`: fix what is MISSING (ask before installs and sudo), skip per-stack rows no project needs.
5. For every kit in ~/.config/ai-kit/projects.tsv: `bash ~/ai-kit/bin/kit-update <kit>`; for each REVIEW file show the
   diff and ask which version to keep. A repo without a kit: offer "setup the kit for this project".
6. Remind what only the user can do (logins, `/codex:setup`, `/claude-hud:setup`) and that hooks load in a NEW session.

## When the user says "setup the kit for this project" (from inside a project repo)
The kit never goes into the repo. Ask the user where to keep this project's kit (suggest a sibling or ~/kits/<repo>),
then run `bash ~/ai-kit/bin/kit-new <repo> <kit-folder>` (explain in the popup what it changes), install that stack's rows
from MANIFEST "Per stack" (ask before each), then tell the user to start a NEW claude session in the repo: the
ai-kit-workflow plugin loads the kit, and the onboarding in `$KIT/.ai/KIT.md` starts.

## When the user says "update the kit" (in a project repo, or for all kits)
`git -C ~/ai-kit pull`, then `bash ~/ai-kit/bin/kit-update <kit-folder>` for this repo's kit (registry:
~/.config/ai-kit/projects.tsv; for all kits, run it for each line). Files the user edited and upstream changed are listed
as REVIEW: show each diff and ask which version to keep, or merge both. Also `claude plugin marketplace update ai-kit`.

## When the user says "add <tool/skill> to the kit"
Check it like `project/.ai/SKILLS.md` "Missing" says (official source, stars, license, last release, what it sends out),
ask the user, then add a row to MANIFEST.md and, if the AI should use it, to `project/.ai/SKILLS.md`.

## Third-party plugins (the ai-kit marketplace)
Reviewed third-party plugins are listed in `.claude-plugin/marketplace.json`, each pinned to a full commit `sha`, so every
machine installs exactly the reviewed code: `claude plugin marketplace add inujustin/ai-kit` then `claude plugin install <name>@ai-kit`.
To add or update one: read its hooks/scripts for network calls and commands, pick a commit at least 14 days old,
set `sha`, run `claude plugin validate .`, ask the user, then note it in MANIFEST.md and `project/.ai/SKILLS.md`.

## Rule conflicts and rule → hook
Same as in the project kit: on conflicting rules stop and ask (both rules side by side, sources, recommendation);
when a rule is mechanical, repeated or forgotten, ask whether to make it a hook, again each time, unless the user said
"no for this whole session". See `project/CLAUDE.local.md` and `project/.ai/HOOKS.md`.

## Git for this repo
- Work on `ai/claude/<date>-<name>` branches; ask the user whether to merge into main when a piece is done.
- The repo is public. Before every commit: `bash bin/doctor --leak-check` must pass (no company names, emails,
  client code or data; leak words live outside the repo in ~/.config/ai-kit/leak-words).
- The user pushes (`git push` is blocked for the AI); tell them when main is ready.
