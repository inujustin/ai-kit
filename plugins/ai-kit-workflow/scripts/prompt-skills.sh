#!/usr/bin/env bash
# UserPromptSubmit: the user writes short, high-level prompts and does not name skills. This hook reads the prompt,
# matches keywords (Vietnamese and English) and prints skill hints; plain stdout is added to Claude's context.
# Hints only: Claude still decides, invokes the skills that fit, says in one line which, and asks when unsure.
# Keep the map in sync with $KIT/.ai/SKILLS.md. Works in any repo; mentions the kit only where one is registered. Prints nothing for short replies such as "ok", "yes", "merge".
KIT="$(bash "$(dirname "$0")/kit-resolve.sh" "$PWD" 2>/dev/null)" python3 -c '
import json, os, re, sys
try:
    d_in = json.load(sys.stdin)
except Exception:
    sys.exit(0)
p, sid = d_in.get("prompt", ""), d_in.get("session_id", "x")
text = p[:3000].lower()
if len(text.strip()) < 15:
    sys.exit(0)
rules = [
    (r"tính năng|chức năng|màn hình|làm (cái|trang|module)|feature|implement|build|thêm mới|new page", "new or vague feature: grilling, then domain-modeling, then tickets from .ai/tickets/TEMPLATE.md (mattpocock + kit); ask on reuse first"),
    (r"lỗi|bug|error|không chạy|ko chạy|fail|crash|exception|traceback|sai rồi|hỏng", "bug: diagnosing-bugs (mattpocock); stuck after 2 tries: /codex:rescue"),
    (r"\btest|kiểm thử|tdd|unit", "tests: tdd (mattpocock); risky logic: tester/coder split (.ai/WORKFLOW.md)"),
    (r"review|xem lại|soát|check code|kiểm tra code", "review: code-review; Frappe code: frappe-code-review; risky diff: bash .ai/bin/gate"),
    (r"bảo mật|security|phân quyền|permission|quyền|auth|login|token|upload|secret", "security-sensitive: /security-review"),
    (r"frappe|erpnext|doctype|bench|whitelist|hooks\.py|desk", "Frappe: frappe-app-dev (writing), frappe-code-review (reviewing), pack rules .ai/packs/frappe/RULES.md"),
    (r"thư viện|library|package|version|docs|tài liệu api|api của", "library/API facts: Context7 (no client code in the query)"),
    (r"ở đâu|where is|kiến trúc|architecture|luồng|flow|gọi tới|who calls|codebase", "find your way in the code: graphify, or an Explore subagent"),
    (r"gọn|đơn giản|simplif|refactor|clean ?up|thừa|dư thừa|bloat", "simplify: ponytail-review / ponytail-audit (list only), then /simplify"),
    (r"giao diện|\bui\b|css|layout|console|network|trình duyệt|browser", "browser/UI: chrome-devtools-mcp"),
    (r"merge|push|pull request|\bpr\b|commit", "git: small commits on the current branch per .ai/WORKFLOW.md, PR body with the pr skill; remote follows REMOTE in .ai/mode.conf (guard-git popups)"),
    (r"hết (quota|limit)|rate limit|usage limit|tài khoản|account|đổi acc|switch acc", "accounts: $KIT/.ai/bin/account (list, add, next; same tool only: Claude to Claude, Codex to Codex); progress stays in .ai/run and handoff.md"),
    (r"nhiều project|các project|project khác|ưu tiên|priority|projects", "many projects: python3 $KIT/.ai/bin/projects (read-only table); one team per project, never mix their code or notes; PRIORITY in .ai/mode.conf"),
    (r"hook|luật|rule|quy tắc|lặp lại|nhắc lại", "rules: check .ai/HOOKS.md, ask whether this should become a hook"),
    (r"setup|cài đặt|update (the )?kit|cập nhật kit|kiểm tra lại|check (again|the setup)|ai-kit", "setup refresh: follow ~/ai-kit/CLAUDE.md \"When the user says the setup or the kit changed\" (pull, plugins, doctor, kit-update, report)"),
]
hits = [hint for pat, hint in rules if re.search(pat, text)]
act = re.search(r"\b(làm|sửa|fix|thêm|xoá|xóa|tạo|viết|cài|chạy|implement|build|add|create|write|install|run|refactor|merge|push)\b", text)
question = re.match(r"\s*/?btw\b", text) or text.rstrip().endswith("?") or re.search(r"\b(là gì|tại sao|vì sao|thế nào|như nào|có nên|khác gì|how|what|why|which|should i|is it)\b", text)
# Plan mode only when the user asks for a plan; never switched on from keywords (it stopped long runs).
big = re.search(r"plan mode|lên kế hoạch|lập kế hoạch|\bplan (it|this|first)|make a plan|kế hoạch trước", text)
kit = os.environ.get("KIT", "")
map_ = (kit + "/.ai/SKILLS.md") if kit else "the installed skills"
print("ai-kit skill check: pick the skills that fit this prompt from " + map_ + ", invoke them, say in one line which; ask the user if unsure or if a missing skill would help. Repo rules beat kit rules; on any conflict ask.")
if question and not act:
    print("- mode: this looks like a question only: answer it cheaply and briefly; no edits, no state-changing commands, no plan mode, no agents.")
elif big and act:
    print("- mode: the user asked for a plan: plan mode, plan, ask once to approve (unattended or \"ask nothing\": go straight on). The plan-record hook saves it.")
if kit and act and os.path.isfile(kit + "/.ai/PRACTICES.md"):
    print("- practices: check " + kit + "/.ai/PRACTICES.md; a practice that fits this task and is not applied/no: grill the user with AskUserQuestion (apply now / not now).")
# Forget signals: keep in sync with $KIT/.ai/PRACTICES.md "Catalog".
# No grills while the user is away: "ask nothing" words, an unattended run ($KIT/.ai/run/auto) or an opened kit.
unattended = bool(kit) and any(os.path.exists(kit + "/.ai/run/" + f) for f in ("auto", "open-until"))
nogrill = unattended or re.search(r"no grill|just do it|khỏi hỏi|đừng hỏi|làm luôn|ask nothing|đừng hỏi lại|dont ask|don.t ask", text)
bps = [
    ("BP-1", r"lại sai|đã nói rồi|nhắc lại|lần trước|như mọi khi|\bagain\b|i told you|as before", "look back at session history; repeated work becomes a skill or hook"),
    ("BP-2", r"xong chưa|xong rồi|\bmerge\b|\bship\b|\bdone\b|\bpush\b", "self-review before saying done"),
    ("BP-3", r"vẫn lỗi|khó quá|\bbí\b|thử lại|still fail|stuck|tried twice", "effort follows risk; ask before raising effort"),
    ("BP-4", r"thêm cả|thêm luôn|nhân tiện|à mà|also add|while you.re at it", "new idea mid-task becomes a backlog ticket"),
    ("BP-5", r"mỗi ngày|hằng ngày|mỗi sáng|hàng tuần|định kỳ|every (day|week|morning)", "scheduled job instead of doing it by hand"),
    ("BP-7", r"chuyển qua|việc khác|task khác|giờ làm|new task|switch to|unrelated", "topic changed: delegate it to a subagent or Codex ticket to keep this session clean; never ask the user for /clear"),
    ("BP-8", r"mai làm tiếp|để sau|tạm dừng|hết limit|continue tomorrow|pick up later", "write the session handoff before stopping"),
    ("BP-11", r"24/7|tự động hết|chạy cả ngày|lúc tôi ngủ|solopreneur|solo preneur|không cần mở máy|while i sleep", "24/7 automation for owned projects is not in the kit yet: research the official options (cloud agents, CI gate, auto-merge, preview deploys, nightly jobs) and offer them one by one"),
    ("BP-10", r"không hiểu|giải thích|chạy thế nào|luồng này|how does it work|explain", "explain in levels: short text first, diagram on request, always with file:line and test evidence"),
]
grills = [] if nogrill else [(i, h) for i, pat, h in bps if re.search(pat, text)]
if not nogrill and not grills and act and len(text.split()) < 12 and not re.search(r"[\w-]+\.\w{1,4}\b|/", text):
    grills.append(("BP-6", "short action prompt without details: ask for goal, acceptance, example first"))
# Grill each practice at most once per session (the user decides once; "not now" is asked again in a later session).
import tempfile
seen_f = os.path.join(tempfile.gettempdir(), "ai-kit-grilled-" + sid)
try:
    seen = set(open(seen_f).read().split())
except Exception:
    seen = set()
if kit and act and re.search(r"sửa|thêm|làm|viết|tạo|fix|add|build|implement|code|feature|tính năng|chức năng", text):
    grills.append(("TESTS", "tests for this work: ask write tests / skip with manual checks (facts: bash " + kit + "/.ai/bin/test-scan); record Tests: in the ticket"))
# Work profile ($KIT/.ai/mode.conf): never fixed for life; ask again when the work changes shape.
if kit and not nogrill:
    prof = {}
    try:
        for line in open(kit + "/.ai/mode.conf"):
            m = re.match(r"^([A-Z_]+)=(.*)$", line.strip())
            if m: prof[m.group(1)] = m.group(2).strip("\x27\"")
    except Exception:
        pass
    cur = ", ".join(k + "=" + prof.get(k, "?") for k in ("REPO_ROLE", "KIT_GIT", "BUDGET", "BRANCHES", "REMOTE", "PROVIDERS", "ROLE_DEV", "ROLE_REVIEW", "TEST_POLICY"))
    if act:
        grills.append(("PROFILE", "work profile (" + cur + ", from " + kit + "/.ai/mode.conf): at the first task of this session show these values in plain words and ask whether they still fit this work"))
    if re.search(r"nhánh|branch|checkout|song song|parallel|nhiều project|multi", text):
        grills.append(("PROFILE-BRANCH", "branches: ask how to work this time: one branch / several in turn; which branch names the AI may create or switch by itself (BRANCHES ask|auto, AUTO_BRANCH_ERE); branches are done in turn in the one checkout, never a worktree, clone or copy; a new feature = commit, then a new branch from the base (WORKFLOW.md Branches)"))
    if re.search(r"tạo repo|repo mới|new repo|git init|tôi là chủ|của tôi|i own|my repo|join|vào team|repo công ty|repo của team", text):
        grills.append(("PROFILE-OWNERSHIP", "ownership: ask whether the user joined or created this repo (REPO_ROLE joined|owner), which AI files the repo already has (team rules first), and whether the kit should have its own git (KIT_GIT none|local|remote); only project code ever enters the repo"))
    if re.search(r"thêm (ai|acc|account|tài khoản)|account mới|tài khoản mới|agy|gemini|antigravity|provider|nhà cung cấp|model khác|\bai khác", text):
        grills.append(("PROFILE-PROVIDERS", "AI providers: the user mentions an AI or account: ask whether to add it on this machine ($KIT/.ai/bin/account add <tool> <name> <purpose> <plan>) and to this project (PROVIDERS, max 4; Claude + Codex first, free ones only Size: tiny tickets); show bash $KIT/.ai/bin/account plan and ask whether the roles (ROLE_DEV, ROLE_REVIEW, ROLE_TINY) should change"))
    if re.search(r"push|pull request|\bpr\b|remote|github|gitlab|deploy|release", text):
        grills.append(("PROFILE-REMOTE", "remote: ask how careful to be in this project: popup every time / feature-branch push without popup / never (REMOTE ask|feature|never); for one long run only: may the AI push by itself (touch $KIT/.ai/run/allow-push) or commit only and the user pushes later"))
    if re.search(r"xuyên đêm|qua đêm|overnight|chạy dài|long.?run|cả ngày|nhiều agent|song song|parallel|tối đa|\bmax\b|tiết kiệm|quota|limit|tốn|chi phí|cost|bản sao|clone|copy", text):
        grills.append(("PROFILE-BUDGET", "resources: ask how much to spend on this (BUDGET lean|normal|max): model, effort, number of agents, how long; say the expected cost in one line; never copy the project to be safe"))
grills = [(i, h) for i, h in grills if i not in seen][:4]
if grills:
    open(seen_f, "a").write(" ".join(i for i, _ in grills) + " ")
for i, h in grills:
    if i.startswith(("PROFILE", "TESTS")):
        print("- grill NOW: " + i + " " + h + ". Before doing anything else in this turn, ask with AskUserQuestion (batch with the other grills, max 4); write a changed value to mode.conf and say so in one line.")
    else:
        print("- grill NOW: " + i + " " + h + ": the prompt shows the user may have forgotten it. Before doing anything else in this turn, check its status in .ai/PRACTICES.md; proposed or not now: ask with AskUserQuestion (apply now / not now / no for this session).")
if re.search(r"https?://|tip|mẹo|best practice|thực hành tốt|video|tiktok|facebook|github\.com", text):
    print("- lead: a pasted tip or link is a lead: check the real source (SKILLS.md Missing), add it to .ai/PRACTICES.md, ask.")
# Matched skills are used without asking (global stays loose); the hint is printed in full once per session.
skill_seen_f = os.path.join(tempfile.gettempdir(), "ai-kit-skills-" + sid)
try:
    skill_seen = set(open(skill_seen_f).read().split("\n"))
except Exception:
    skill_seen = set()
new = [h for h in hits[:4] if h not in skill_seen]
if new:
    open(skill_seen_f, "a").write("\n".join(new) + "\n")
for h in hits[:4]:
    if h in new:
        print("- skill: " + h + " -> use it when it fits, no question; say in one line which and why.")
    else:
        print("- hint: " + h + " (already used this session)")
if act and not hits:
    print("- skill check: no keyword match; look at " + map_ + " yourself and use one that fits, no question.")
'
exit 0
