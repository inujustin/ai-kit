# Skills and plugins: what to use when, and how new ones get added

The user talks in plain language and does not remember skill names. **You pick and invoke them yourself**,
and say in one line which ones you use. Never ask the user to type a slash command.
Before relying on an entry, check it is really installed (`/skills`, `/plugin`); if not, see "Missing" below.

## Map (situation -> what you use)
| Situation | Use | Source |
|---|---|---|
| New feature, vague or big request | `grill-with-docs` (or `grill-me`), then `to-spec`, then `to-tickets` | mattpocock-skills |
| Bug, error, "it does not work" | `diagnosing-bugs` | mattpocock-skills |
| Write tests first for risky logic | `tdd` | mattpocock-skills |
| End of a week or after a repeated mistake | `retro`, then propose a line for AGENTS.md or a CI rule | mattpocock-skills |
| Writing or editing any code | `code-style` | user skill (~/.claude/skills) |
| Frappe: DocType, controller, hook, whitelisted API, bench, permissions, Frappe test | `frappe-app-dev` | user skill (Frappe official) |
| Reviewing Frappe code | `frappe-code-review` | user skill (Frappe official) |
| Reviewing any diff before merge or PR | `/code-review`; risky diff: `bash .ai/bin/gate` too | built-in / Codex |
| Auth, permissions, uploads, raw input, secrets | `/security-review` | built-in |
| Cleanup after a feature works | `/simplify` | built-in |
| Second opinion, stuck for 2 tries, plan critique | `/codex:review`, `/codex:rescue` | codex plugin (OpenAI) |
| Clear ticket > ~30 lines, or several independent tickets | `bash .ai/bin/dispatch .ai/tickets/<id>.md` (background, parallel) | this kit |
| Library or framework API you are unsure of | Context7 (never put client code or data in the query) | context7 plugin |
| Big or unfamiliar codebase: where is X, what calls Y, how modules connect | graphify: `/graphify .` once (code is parsed locally; docs/PDFs go through this session's model), then query the graph instead of reading many files. Use `--code-only` on client repos | graphify CLI 0.9.80 (Graphify-Labs, Apache-2.0) |
| Python / TS type errors and go-to-definition | pyright-lsp, typescript-lsp (automatic) | Anthropic marketplace |
| SPA in the browser: console, network, layout, performance | chrome-devtools-mcp | Anthropic marketplace |
| Context window and token use (status line) | claude-hud (local only, no network) | jarrodwatts/claude-hud, MIT |

## Missing: when a skill or plugin would help
1. Only propose from official sources: the `claude-plugins-official` marketplace (Anthropic), or the vendor's own
   GitHub org (frappe/, openai/, vuejs/, microsoft/...). Never from screenshots, videos, blogs or open registries (no find-skills).
2. Check it first: `curl -s https://api.github.com/repos/<owner>/<repo>` (stars, license, last push, archived),
   and read its SKILL.md / plugin files for anything that runs commands, sends data out, or auto-updates.
3. Ask the user with AskUserQuestion: what it adds, source URL, stars, license, the exact install command,
   project or user scope, and how to remove it. Recommend one option.
4. The user runs the install. Then add a row to the map above (this file is the kit's memory).

## Tools the user reviews with (offer them, do not install)
- Terminal: `lazygit` (branches, commits, diffs, worktrees). Closer look: VS Code with the Git Graph extension.
- When you finish work the user should review, name the branch and commits so they can find them in lazygit or Git Graph.
- Conflicts: explain each one in plain words and ask which side to keep; never resolve silently.
