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
    (r"tính năng|chức năng|màn hình|làm (cái|trang|module)|feature|implement|build|thêm mới|new page", "new or vague feature: grilling, then domain-modeling, then plan mode and tickets from .ai/tickets/TEMPLATE.md (mattpocock + kit); ask on reuse first"),
    (r"lỗi|bug|error|không chạy|ko chạy|fail|crash|exception|traceback|sai rồi|hỏng", "bug: diagnosing-bugs (mattpocock); stuck after 2 tries: /codex:rescue"),
    (r"\btest|kiểm thử|tdd|unit", "tests: tdd (mattpocock); risky logic: tester/coder split (.ai/WORKFLOW.md)"),
    (r"review|xem lại|soát|check code|kiểm tra code", "review: code-review; Frappe code: frappe-code-review; risky diff: bash .ai/bin/gate"),
    (r"bảo mật|security|phân quyền|permission|quyền|auth|login|token|upload|secret", "security-sensitive: /security-review"),
    (r"frappe|erpnext|doctype|bench|whitelist|hooks\.py|desk", "Frappe: frappe-app-dev (writing), frappe-code-review (reviewing), pack rules .ai/packs/frappe/RULES.md"),
    (r"thư viện|library|package|version|docs|tài liệu api|api của", "library/API facts: Context7 (no client code in the query)"),
    (r"ở đâu|where is|kiến trúc|architecture|luồng|flow|gọi tới|who calls|codebase", "find your way in the code: graphify, or an Explore subagent"),
    (r"gọn|đơn giản|simplif|refactor|clean ?up|thừa|dư thừa|bloat", "simplify: ponytail-review / ponytail-audit (list only), then /simplify"),
    (r"giao diện|\bui\b|css|layout|console|network|trình duyệt|browser", "browser/UI: chrome-devtools-mcp"),
    (r"merge|push|pull request|\bpr\b|commit", "git: story commits per .ai/WORKFLOW.md (bash .ai/bin/story), PR body with the pr skill; ask before merge/push"),
    (r"hook|luật|rule|quy tắc|lặp lại|nhắc lại", "rules: check .ai/HOOKS.md, ask whether this should become a hook"),
    (r"setup|cài đặt|update (the )?kit|cập nhật kit|kiểm tra lại|check (again|the setup)|ai-kit", "setup refresh: follow ~/ai-kit/CLAUDE.md \"When the user says the setup or the kit changed\" (pull, plugins, doctor, kit-update, report)"),
]
hits = [hint for pat, hint in rules if re.search(pat, text)]
act = re.search(r"\b(làm|sửa|fix|thêm|xoá|xóa|tạo|viết|cài|chạy|implement|build|add|create|write|install|run|refactor|merge|push)\b", text)
question = text.rstrip().endswith("?") or re.search(r"\b(là gì|tại sao|vì sao|thế nào|như nào|có nên|khác gì|how|what|why|which|should i|is it)\b", text)
big = re.search(r"tính năng|chức năng|màn hình|module|thiết kế|design|kiến trúc|architecture|feature|migrate|nhiều file|toàn bộ|whole", text)
kit = os.environ.get("KIT", "")
map_ = (kit + "/.ai/SKILLS.md") if kit else "the installed skills"
print("ai-kit skill check: pick the skills that fit this prompt from " + map_ + ", invoke them, say in one line which; ask the user if unsure or if a missing skill would help. Repo rules beat kit rules; on any conflict ask.")
if question and not act:
    print("- mode: this looks like a question only: answer it cheaply and briefly; no edits, no state-changing commands, no plan mode, no agents.")
elif big and act:
    print("- mode: big or vague request: enter plan mode, plan (subagents allowed), then ask the user to approve before editing.")
if kit and act and os.path.isfile(kit + "/.ai/PRACTICES.md"):
    print("- practices: check " + kit + "/.ai/PRACTICES.md; a practice that fits this task and is not applied/no: grill the user with AskUserQuestion (apply now / not now).")
# Forget signals: keep in sync with $KIT/.ai/PRACTICES.md "Catalog".
nogrill = re.search(r"no grill|just do it|khỏi hỏi|đừng hỏi|làm luôn đi", text)
bps = [
    ("BP-1", r"lại sai|đã nói rồi|nhắc lại|lần trước|như mọi khi|\bagain\b|i told you|as before", "look back at session history; repeated work becomes a skill or hook"),
    ("BP-2", r"xong chưa|xong rồi|\bmerge\b|\bship\b|\bdone\b|\bpush\b", "self-review before saying done"),
    ("BP-3", r"vẫn lỗi|khó quá|\bbí\b|thử lại|still fail|stuck|tried twice", "effort follows risk; ask before raising effort"),
    ("BP-4", r"thêm cả|thêm luôn|nhân tiện|à mà|also add|while you.re at it", "new idea mid-task becomes a backlog ticket"),
    ("BP-5", r"mỗi ngày|hằng ngày|mỗi sáng|hàng tuần|định kỳ|every (day|week|morning)", "scheduled job instead of doing it by hand"),
    ("BP-7", r"chuyển qua|việc khác|task khác|giờ làm|new task|switch to|unrelated", "topic changed: delegate it to a subagent or Codex ticket to keep this session clean; never ask the user for /clear"),
    ("BP-8", r"mai làm tiếp|để sau|tạm dừng|hết limit|continue tomorrow|pick up later", "write the session handoff before stopping"),
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
grills = [(i, h) for i, h in grills if i not in seen][:3]
if grills:
    open(seen_f, "a").write(" ".join(i for i, _ in grills) + " ")
for i, h in grills:
    print("- grill NOW: " + i + " " + h + ": the prompt shows the user may have forgotten it. Before doing anything else in this turn, check its status in .ai/PRACTICES.md; proposed or not now: ask with AskUserQuestion (apply now / not now / no for this session).")
if re.search(r"https?://|tip|mẹo|best practice|thực hành tốt|video|tiktok|facebook|github\.com", text):
    print("- lead: a pasted tip or link is a lead: check the real source (SKILLS.md Missing), add it to .ai/PRACTICES.md, ask.")
for h in hits[:4]:
    print("- hint: " + h)
'
exit 0
