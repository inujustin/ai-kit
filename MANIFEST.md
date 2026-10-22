# Manifest: everything the kit installs (checked 2026-10-22)

"resolve" = at setup time, newest official release that is at least 14 days old; write the version used here.
Scope: user = only this Linux user. sudo = system package (see SETUP.md "sudo").

## 1. System packages (sudo, apt on Ubuntu/Debian)
| Package | Why |
|---|---|
| git curl ca-certificates build-essential unzip | basics |
| bubblewrap socat | Claude Code sandbox on Linux (never remove; mark manual: `apt-mark manual bubblewrap socat`) |
| pipx | isolated Python CLIs |
| zenity | password popup for `sudo -A` (only on machines with a desktop/WSLg) |
| gh (from GitHub's official apt repo, cli.github.com) | GitHub CLI, PRs, multiple accounts |
| Docker Engine + compose plugin (Docker's official apt repo, docs.docker.com/engine/install/ubuntu — never the snap) | run app stacks (e.g. Frappe, DB, Redis). Then `sudo usermod -aG docker $USER` and log in again |
| openssh-server (VMs only) | VS Code Remote-SSH into the VM; key auth only, see machine/VM.md |

## 2. User tools
| Tool | Pin | Source | Install |
|---|---|---|---|
| nvm + Node LTS | resolve (this machine: Node 24.21.0) | github.com/nvm-sh/nvm (git clone at the tag, as its README "Git Install" says) | then `nvm install --lts` |
| uv | 0.12.17 | github.com/astral-sh/uv | `pipx install uv==0.12.17` |
| Claude Code | resolve (this machine: 2.1.308) | code.claude.com/docs (official native installer) | download installer, read, run |
| Codex CLI | 0.162.1 | github.com/openai/codex (npm `@openai/codex`) | `npm install -g @openai/codex@0.162.1` |
| pre-commit | 4.6.2 | github.com/pre-commit/pre-commit | `uv tool install pre-commit==4.6.2` |
| lazygit | v0.66.0 | github.com/jesseduffield/lazygit (MIT, 83k★) | release tarball, check sha256 against the release's checksums.txt (it names the file `linux` in lowercase), then `install -m 755 lazygit ~/.local/bin/` |
| pyright, typescript-language-server, typescript | 1.1.414, 6.0.1, 7.0.2 | npm (Microsoft / typescript-language-server org) | `npm install -g pyright@1.1.414 typescript-language-server@6.0.1 typescript@7.0.2` |
| graphify | 0.9.80 | github.com/Graphify-Labs/graphify (Apache-2.0), PyPI `graphifyy` | `uv tool install "graphifyy==0.9.80"` then `graphify install --platform claude` |

## 3. Claude Code plugins (user scope)
| Plugin | Marketplace | Note |
|---|---|---|
| mattpocock-skills | claude-plugins-official (Anthropic) | harness: grill, spec, tickets, tdd, debug, retro. Never together with superpowers |
| context7 | claude-plugins-official | library docs; never put client code in queries |
| pyright-lsp, typescript-lsp | claude-plugins-official | need the npm servers above |
| chrome-devtools-mcp | claude-plugins-official | browser debugging |
| codex | `openai/codex-plugin-cc` (OpenAI, Apache-2.0) | add marketplace first; then `/codex:setup` in Claude; turn off auto-update for this marketplace |
| claude-hud | `jarrodwatts/claude-hud` (MIT, local only) | add marketplace first; then `/claude-hud:setup` in Claude |

Not installed on purpose: superpowers, ECC, gstack (clash with mattpocock); find-skills (unvetted registry);
claude-code-router, firecrawl, repomix, claude-mem (send code or context to other services); playwright MCP (overlaps chrome-devtools).

## 4. Skills (user scope, `~/.claude/skills/`)
| Skills | Pin | Source | Install |
|---|---|---|---|
| frappe-app-dev, frappe-code-review, code-style | commit 0bef982e933705c30706efc1db3bc3bc5e7aca62 | github.com/frappe/skills (official Frappe; no license file yet) | git clone, checkout the pin, copy `skills/<name>/` folders |
| graphify | with graphify | `graphify install --platform claude` | (also appends 3 lines to ~/.claude/CLAUDE.md) |

## 5. Settings (ask first, merge, never overwrite)
- `~/.claude/settings.json`: env `DO_NOT_TRACK=1`, deny reads of ~/.ssh, ~/.aws, ~/.codex/auth.json, .env, *.pem, *.key; sandbox enabled.
- Codex: `codex mcp add context7 --url https://mcp.context7.com/mcp` (optional).
- Privacy (user does it in the web UI): claude.ai › Settings › Privacy: model training off; ChatGPT › Data controls: "Improve the model" off.
