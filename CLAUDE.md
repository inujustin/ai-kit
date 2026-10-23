# ai-kit (personal, public repo github.com/inujustin/ai-kit)

This folder is the user's portable AI setup. It contains no client or company data and must never receive any.
Reply in the user's language (Vietnamese by default), short and plain. Grill with AskUserQuestion at each real decision.
Every permission popup and every question carries its own brief explanation in the user's language (what, what it
changes, why, remote or not, undo, which option); the user reads the popup, not the chat. One step per permission.
Only Claude (plus Codex) models: never install free model routers or switchers (omniroute, claude-code-router, cc-switch).

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
