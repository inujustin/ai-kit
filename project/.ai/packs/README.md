# Stack packs

A pack = the rules and checks for one stack. A project activates packs in `.ai/packs.conf` (`PACKS=(...)`); several can be
active (e.g. a Python backend + a TypeScript frontend). The core kit works with no pack at all.

Each pack folder has:
| File | What |
|---|---|
| RULES.md | rules the agents follow, each with a code (e.g. GO-3) and the official source it comes from |
| antipatterns.rules.sh | grep checks for the rules marked [CI], run on changed files only |
| verify.conf.example | lint / type / test / build commands to copy into `.ai/verify.conf` |

## Make a pack for a new stack (during onboarding, with the user)
1. Copy the closest pack folder (or start empty) to `.ai/packs/<stack>/`.
2. Rules come only from: official docs or official skills of the framework/language, and the project's own agreed rules
   (lint config, CONTRIBUTING, team docs the user confirms are final). Cite the source next to each rule. No rules from memory.
3. Turn only clearly greppable rules into `antipatterns.rules.sh` lines; the rest stay review rules.
4. `verify.conf.example`: the project's real commands (from its package scripts, Makefile, CI).
5. Show the pack to the user, then add it to `PACKS=(...)` and to MANIFEST.md "Per stack" in ~/ai-kit, so the next project reuses it.

Packs included: `frappe` (Frappe / ERPNext), `web-ts` (TypeScript / JavaScript web apps).
