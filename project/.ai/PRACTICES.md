# Best practices: you notice them, I decide

I collect tips from videos, posts and docs, and I will not remember them. You must: when a practice below fits the
work in front of you and its status is not "applied" or "no", stop and grill me about it with AskUserQuestion, the
same way HOOKS.md works for rule → hook.

## When to check this file
- At the start of every non-trivial task (the UserPromptSubmit hook reminds you), at the end of a long task, at the
  weekly look-back, at onboarding and "review the kit".
- When I paste a new tip, link or screenshot: treat it as a lead (SKILLS.md "Missing": find the real source, check it),
  then add a row below with status "proposed" and ask me.

## How to ask (every time a practice fits)
One AskUserQuestion: the practice in one plain line, why it fits this task right now, what applying it changes
(file, hook, skill or habit), cost and risk, how to undo. Options: "apply now" (recommended when it clearly fits) /
"not now" / "no for this whole session" / "never" (only if I say so).
- "apply now": make the change in THIS kit (AGENTS.md, a pack, a hook, a ticket field), set status "applied" with the
  date and where it lives. If it would help every project, say so; I promote it from ~/ai-kit.
- "not now": keep the row, ask again the next time it fits. "no for this whole session": stop until the session ends.
- "never": set status "no" with my reason.
Several practices fit at once: one multiSelect question, max 4, best first.

## Catalog
"Forget signals" are words in my prompt that show I forgot the practice. The UserPromptSubmit hook matches them
(plugin prompt-skills.sh, keep both in sync) and prints `grill: BP-x`; you then check the status here and ask.
"no grill" / "just do it" in my prompt turns these off for that prompt.

| ID | Practice | Forget signals (VI / EN) | What applying means | Status |
|---|---|---|---|---|
| BP-1 | Look back at session history: read this repo's Claude Code transcripts (`~/.claude/projects/<encoded-repo-path>/*.jsonl`) for repeated corrections, things I explained twice, steps done by hand 3+ times; repeated work becomes a skill or hook | "lại sai", "đã nói rồi", "nhắc lại", "lần trước", "như mọi khi", "again", "I told you", "as before"; also the weekly look-back | propose AGENTS.md lines, pack rules, hooks or skills, one question each; never edit on your own. Transcripts are kept 30 days by default (`cleanupPeriodDays`); never copy their text off this machine | proposed |
| BP-2 | Self-check before handing to the reviewer: list logic holes, skipped edge cases, a simpler option. It never replaces the independent review (WORKFLOW.md "Separate contexts": the writer never reviews its own code) | "xong chưa", "xong rồi", "merge", "ship", "done?", "push" | a short "Holes I checked" list in the final message | proposed |
| BP-3 | Model and effort follow risk (small question = answer directly at low cost: no plan mode, no subagents, at most one quick read): plan with the big model, hand searches to Explore subagents on a small model, give clear tickets to Codex; `AI_CODEX_EFFORT=high` for Split=yes tickets, `gate <base> xhigh` for security or money diffs; ask me before switching Claude to a higher effort or ultrathink | "vẫn lỗi", "khó quá", "bí", "thử lại", "still failing", "stuck", "tried twice" | the env/arg on dispatch and gate; one line saying which effort and why | proposed |
| BP-4 | Small finishable steps: Size S tickets; a new idea mid-task becomes a backlog ticket, not more scope | "thêm cả", "thêm luôn", "nhân tiện", "à mà", "also add", "while you're at it" | split the ticket; the extra idea goes to `.ai/tickets/` with status backlog | proposed |
| BP-5 | Scheduled jobs (nightly issue triage → draft tickets; nightly full verify → report) | "mỗi ngày", "hằng ngày", "mỗi sáng", "hàng tuần", "định kỳ", "every day", "every week" | a scheduled Claude Code routine or GitHub Action; ask about cost and what it may read | proposed |
| BP-6 | Ask for the details first: a short action prompt with no goal, no acceptance and no example gets clarifying questions before any work; ask for a real example (a sample file, screenshot, an existing screen to copy) rather than a description | action prompt under ~12 words that names no file, screen or expected result | grilling first (mattpocock `grilling`); acceptance items go into the ticket | proposed |
| BP-7 | One long session, kept clean by you: I want few sessions and no commands. New or side tasks, wide searches and long logs go to subagents or Codex (their context is thrown away; only a short result comes back); before auto-compact, update handoff.md (BP-8) so nothing is lost. Never ask me to type `/clear` or `/compact`, except the renew question at ~70% context (context-watch hook): then write handoff.md first, and one `/clear` from me carries everything over | "chuyển qua", "việc khác", "task khác", "giờ làm", "new task", "switch to", "unrelated" | delegate the new task to a subagent or a Codex ticket and say so in one line | proposed |
| BP-11 | 24/7 automation for projects I own (solopreneur level). The kit today is NOT enough for this: it needs a session on my machine. Missing, to research in official docs and offer one by one when REPO_ROLE=owner: (1) cloud agents started from an issue or a schedule that open PRs while my machine is off (Claude Code on the web / GitHub app or Action, Codex cloud, routines); (2) CI as the gate on every PR (tests, lint, build) and auto-merge of green low-risk PRs; (3) a preview deploy per PR; (4) nightly jobs (triage, dependency updates, reports; BP-5); (5) production errors turned into tickets automatically. Never on company or joined repos without the team's OK | "24/7", "tự động hết", "chạy cả ngày", "lúc tôi ngủ", "solopreneur", "startup", "không cần mở máy", "while I sleep" | research the current official option for each item, then ask which to set up (one at a time, cost and risk each); record what is live in AGENTS.md "Project" | proposed |
| BP-10 | Explain in levels: when I need to understand code, a flow, or what the agent team just did: level 1 = short clear text that explains the thing itself (what, why, what it means for me), never a narration of commands run or files read, never "read the code"; level 2 = an HTML diagram (the footprint template style; no mermaid) or a graphify path if I want more; level 3 = an interactive HTML page only when I ask; never a video. Every level cites file:line and real run evidence (tests, logs): a nice picture does not prove the code is right | "không hiểu", "giải thích", "nó chạy thế nào", "luồng này", "how does it work", "explain" | answer at level 1 first and offer level 2; no HTML unless asked; always file:line + evidence | proposed |
| BP-8 | Session handoff: before `/clear`, at the end of a long session or near the context limit, write `$KIT/.ai/handoff.md` (goal, done, next step, open decisions, files); the next session reads it first. If the kit already has a resume/"làm tiếp" hook, extend that one instead of adding a second | "mai làm tiếp", "để sau", "tạm dừng", "hết limit", "continue tomorrow", "pick up later" | write or update handoff.md (session snapshot); a long run also keeps `run/progress.md` and `run/tasks.json` (LONGRUN.md); session-start points to both | proposed |

## Leads checked (do not re-propose without something new)
| Lead | Verdict | Why |
|---|---|---|
| Understand-Anything (Egonex-AI, MIT) | not now | overlaps graphify; its analysis sends code to the model provider |
| claude-devtools (matt1398, MIT), claude-code-hooks-multi-agent-observability (disler, MIT), Claude-Code-Usage-Monitor (BSD-2) | claude-devtools: chosen 2026-10-26 (install after code review); others not now | checked 2026-10-26: each reads Claude logs only (no Codex runs, tests or per-ticket pass/fail); a dataviz HTML page from local files covers it with nothing installed. If only a Claude session viewer is wanted: claude-devtools in Docker with `--network none` |
| Archify (tt-a1i) | not now | diagrams for people, not agent context; graphify covers navigation |
| super-board (EricTechPro) | no | same Build → QA → Review loop as dispatch/gate; remote install script |
| BuildPartner plugin | no | uploads session data to its service, paid after a free tier; BP-1 does it locally |
| Piaz Switch (multi-account switcher, video 2026-10-18) | no | third-party app holding every login token. The user decided (2026-10-25) to use several accounts with same-tool rotation, accepting the providers' terms risk; the kit does it with its own small `bin/account` + `bin/ai` instead |
| `/goal` command (Nhat Anh video, 2026-10-14) | yes (verified 2026-10-25, code.claude.com/docs/en/goal) | real: keeps a session working until a checkable condition holds, with an evaluator each turn. Only the user can type it, so the kit's auto run (LONGRUN.md) is the default; offer `/goal "<condition> or stop after N turns"` as one copy-ready line for a run with one measurable end state |
| ADE apps: Orca (stablyai, MIT), Warp ADE, AIDEN, Augment Intent (checked 2026-10-25) | no | they make the HUMAN dispatch and compare agents; the kit makes Claude the lead and the user only decides. Extra app with access to company code and accounts; overlaps dispatch and gate. Re-asked 2026-10-25 "one ADE per project with few sessions?": still no, one terminal tab per project running `$KIT/.ai/bin/ai` gives the same, `bin/projects` is the overview |
| `claude agents` (agent view, built into Claude Code, research preview) | not now | a screen of background sessions and the ones waiting for you; useful only to watch and answer, not to dispatch. Each session spends quota on its own |
| `/doctor prompt-audit` (200Lab video, 2026-10-25) | applied (2026-10-25; CHANGELOG 2.1.283, this machine 2.1.310) | KIT.md "Freshness check": read-only at weekly look-back and "review the kit", one question per finding, backup first, ask before scanning every skill |
| prompts.chat | not now | reference only; never bulk-import prompts into a repo; its MCP sends queries outside |
| CodeRabbit (Claude Code + CodeRabbit video) | not now | third-party reviewer that receives the code; Codex gate is already an independent review. Only for personal or public repos, and ask first. Its useful idea (cap fix rounds) is applied in WORKFLOW.md |
| is-agentic.com | not now | checks how agent-friendly a website is; use once a website MVP exists |
| Dify | no (for this kit) | another agent runtime, not Claude Code or Codex; research item for later teams |
| Anthropic professional plugins (Sales, Marketing, Finance, Legal, ...) | later | for teams outside software engineering |
| hccs (multi-identity launcher) | no | third-party launcher with routing to many backends; the kit uses its own `bin/account` + PROVIDERS per project (Claude + Codex first, agy/Gemini CLI tiny tasks only) |
