# ai-kit (personal, private)

This folder is the user's portable AI setup. It contains no client or company data and must never receive any.
Reply in the user's language (Vietnamese by default), short and plain. Grill with AskUserQuestion at each real decision.

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

## Git for this repo
- Work on `ai/claude/<date>-<name>` branches; ask the user whether to merge into main when a piece is done.
- Push only to the user's private repo `inujustin/ai-kit`, step by step, with the user's OK each time.
- Before every commit: `bash bin/doctor --leak-check` must pass (no company names, emails, client code or data).
