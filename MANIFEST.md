# Manifest: everything the kit installs (checked 2026-10-22)

Two parts: **Core** (every machine, any stack) and **Per stack** (install only when a project on this machine uses that stack).
"resolve" = at setup time, newest official release that is at least 14 days old; write the version used here.
Scope: user = only this Linux user. sudo = system package (see SETUP.md "sudo").

# CORE (every machine)

## C1. System packages (sudo, apt on Ubuntu/Debian)
| Package | Why |
|---|---|
| git curl ca-certificates build-essential unzip | basics |
| bubblewrap socat | Claude Code sandbox on Linux (never remove; mark manual: `apt-mark manual bubblewrap socat`) |
| pipx | isolated Python CLIs |
| gh (Ubuntu repo, or GitHub's official apt repo cli.github.com) | GitHub CLI, PRs, multiple accounts |
| Docker Engine + compose plugin (Docker's official apt repo, docs.docker.com/engine/install/ubuntu — never the snap) | run app stacks, databases, caches. Then `sudo usermod -aG docker $USER` and log in again |
| openssh-server (VMs only) | VS Code Remote-SSH into the VM; key auth only, see machine/VM.md |

## C2. User tools
| Tool | Pin | Source | Install |
|---|---|---|---|
| nvm + Node LTS | resolve (this machine: Node 24.21.0) | github.com/nvm-sh/nvm (git clone at the tag, as its README "Git Install" says) | then `nvm install --lts` (Codex and several plugins need Node) |
| uv | 0.12.17 | github.com/astral-sh/uv | `pipx install uv==0.12.17` |
| Claude Code | resolve (this machine: 2.1.308) | code.claude.com/docs (official native installer) | download installer, read, run |
| Codex CLI | 0.162.1 | github.com/openai/codex (npm `@openai/codex`) | `npm install -g @openai/codex@0.162.1` |
| pre-commit | 4.6.2 | github.com/pre-commit/pre-commit | `uv tool install pre-commit==4.6.2` |
| lazygit | v0.66.0 | github.com/jesseduffield/lazygit (MIT, 83k★) | release tarball, check sha256 against the release's checksums.txt (it names the file `linux` in lowercase), then `install -m 755 lazygit ~/.local/bin/` |
| graphify | 0.9.80 | github.com/Graphify-Labs/graphify (Apache-2.0), PyPI `graphifyy` | `uv tool install "graphifyy==0.9.80"` then `graphify install --platform claude` (appends 3 lines to ~/.claude/CLAUDE.md) |
| claude-devtools (optional, needs Docker) | v0.5.0, sha 16cc3c87c1e4d0e08ee101fb52dad1b85dbbe48a | github.com/matt1398/claude-devtools (MIT, 8.7k★); code read 2026-10-26: no outbound calls in the standalone server, updater and SSH stubbed | `git clone --depth 1 --branch v0.5.0` into an empty dir, `docker build -t claude-devtools:0.5.0 <dir>`, then `docker run -d --name claude-devtools --restart unless-stopped -p 127.0.0.1:3456:3456 -v "$HOME/.claude:/data/.claude:ro" -e CORS_ORIGIN=http://127.0.0.1:3456 --read-only --tmpfs /tmp --tmpfs /root --cap-drop ALL --security-opt no-new-privileges claude-devtools:0.5.0`. Never its docker-compose.yml as is (binds every interface; default CORS lets any web page read the sessions). Open http://127.0.0.1:3456 |

## C3. Claude Code plugins (user scope)
| Plugin | Marketplace | Note |
|---|---|---|
| mattpocock-skills | claude-plugins-official (Anthropic) | harness skills enabled by the plugin: grilling, domain-modeling, research, codebase-design, prototype, tdd, diagnosing-bugs, code-review, pr, wizard. The repo has more folders (to-spec, to-tickets…) that the plugin does not enable: check `/skills`, never the folder list. Never together with superpowers |
| context7 | claude-plugins-official | library docs for any stack; never put client code in queries |
| chrome-devtools-mcp | claude-plugins-official | browser debugging for any web app |
| codex | `openai/codex-plugin-cc` (OpenAI, Apache-2.0) | add marketplace first; then `/codex:setup` in Claude; turn off auto-update for this marketplace |
| claude-hud | `jarrodwatts/claude-hud` (MIT, local only) | add marketplace first; then `/claude-hud:setup` in Claude |
| ai-kit-workflow | **`inujustin/ai-kit`** (this repo, `plugins/ai-kit-workflow`) | `claude plugin install ai-kit-workflow@ai-kit`. The kit's hooks for every project with a registered kit; no-op elsewhere except skill hints |
| ponytail | **`inujustin/ai-kit`** (this repo's marketplace, pinned sha 9cc65d03…, v5.1.0, MIT) | `claude plugin marketplace add inujustin/ai-kit` then `claude plugin install ponytail@ai-kit`. Hooks reviewed: local only, no network. Projects set `PONYTAIL_DEFAULT_MODE=lite` |

Not installed on purpose: superpowers, ECC, gstack (clash with mattpocock); find-skills (unvetted registry);
claude-code-router, omniroute, cc-switch (free model routers/switchers; the kit uses official CLIs only); firecrawl, repomix,
claude-mem (send code or context to other services); playwright MCP (overlaps chrome-devtools);
arena-skill (≈600 sub-agent calls per run, 1 commit, malware lookalike account `arena-skiIl`);
BuildPartner plugin (uploads session data, paid), hccs (non-Claude backends), super-board (overlaps dispatch/gate),
Understand-Anything (overlaps graphify), caveman (overlaps ponytail, ≈3% vs "be concise", CLI telemetry on by default). Details: `project/.ai/PRACTICES.md` "Leads checked".

## C4. Settings (ask first, merge, never overwrite)
- Global permissions are open (`bin/global-settings`): `permissions.defaultMode=auto`, allow Bash/Read/Edit/Write/Glob/Grep/
  WebSearch/WebFetch, no `blockReadsOutsideWorkingDirectories`, registered repos and kits in `additionalDirectories`,
  `sandbox.enabled=true` + `autoAllowBashIfSandboxed=true`. Strictness lives per project in the kit, not here.
- `~/.claude/settings.json`: env `DO_NOT_TRACK=1`, deny reads of ~/.ssh, ~/.aws, ~/.codex/auth.json, .env, *.pem, *.key; sandbox enabled.
  Images are read-only for Claude: deny `Edit(**/*.png)` and the same for jpg, jpeg, gif, webp. `Edit(...)` rules cover
  every file-writing tool; `Write(...)` deny rules never match and only cause startup warnings. Set once per machine.
- Codex: `codex mcp add context7 --url https://mcp.context7.com/mcp` (optional).
- Privacy (user does it in the web UI): claude.ai › Settings › Privacy: model training off; ChatGPT › Data controls: "Improve the model" off.

# PER STACK (only when a project needs it)

Detect the stack from the project (manifests, lock files, framework files) during project onboarding, then install only its rows.
Language servers: the `claude-plugins-official` marketplace has `<lang>-lsp` plugins (pyright, typescript, gopls, rust-analyzer,
jdtls, kotlin, csharp, php, ruby, clangd, swift, lua…). Each needs its language server binary; read the plugin's README.

| Stack | Plugins | Tools (pin = resolve unless given) | Skills / packs |
|---|---|---|---|
| Python (any) | pyright-lsp | `npm install -g pyright@1.1.414`; ruff if the project uses it (from its own config) | — |
| TypeScript / JavaScript (any web) | typescript-lsp | `npm install -g typescript-language-server@6.0.1 typescript@7.0.2` | pack `web-ts` |
| Frappe / ERPNext | pyright-lsp, typescript-lsp | as Python + TS | skills frappe-app-dev, frappe-code-review, code-style from github.com/frappe/skills @ 0bef982e933705c30706efc1db3bc3bc5e7aca62 (official; no license file yet): git clone, checkout the pin, copy `skills/<name>/`. Pack `frappe` |
| Go | gopls-lsp | gopls (go.dev) | new pack at onboarding |
| Rust | rust-analyzer-lsp | rust-analyzer via rustup | new pack at onboarding |
| Java / Kotlin | jdtls-lsp / kotlin-lsp | per plugin README | new pack at onboarding |
| .NET | csharp-lsp | per plugin README | new pack at onboarding |
| Other | look in claude-plugins-official first, then the vendor's own GitHub org | official only | new pack at onboarding |

New stack = new row here + a pack folder (see `project/.ai/packs/README.md`), checked with the user. Official sources only.
