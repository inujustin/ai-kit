#!/usr/bin/env bash
# UserPromptSubmit: the user writes short, high-level prompts and does not name skills. This hook reads the prompt,
# matches keywords (Vietnamese and English) and prints skill hints; plain stdout is added to Claude's context.
# Hints only: Claude still decides, invokes the skills that fit, says in one line which, and asks when unsure.
# Keep the map in sync with .ai/SKILLS.md. Prints nothing for short replies such as "ok", "yes", "merge".
python3 -c '
import json, re, sys
try:
    p = json.load(sys.stdin).get("prompt", "")
except Exception:
    sys.exit(0)
text = p[:3000].lower()
if len(text.strip()) < 15:
    sys.exit(0)
rules = [
    (r"tính năng|chức năng|màn hình|làm (cái|trang|module)|feature|implement|build|thêm mới|new page", "new or vague feature: grill-with-docs, then to-spec, then to-tickets (mattpocock); ask on reuse first (AGENTS.md)"),
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
]
hits = [hint for pat, hint in rules if re.search(pat, text)]
act = re.search(r"\b(làm|sửa|fix|thêm|xoá|xóa|tạo|viết|cài|chạy|implement|build|add|create|write|install|run|refactor|merge|push)\b", text)
question = text.rstrip().endswith("?") or re.search(r"\b(là gì|tại sao|vì sao|thế nào|như nào|có nên|khác gì|how|what|why|which|should i|is it)\b", text)
big = re.search(r"tính năng|chức năng|màn hình|module|thiết kế|design|kiến trúc|architecture|feature|migrate|nhiều file|toàn bộ|whole", text)
print("ai-kit skill check: pick the skills that fit this prompt from .ai/SKILLS.md, invoke them, say in one line which; ask the user if unsure or if a missing skill would help.")
if question and not act:
    print("- mode: this looks like a question only: answer it; no edits, no state-changing commands, no agents.")
elif big and act:
    print("- mode: big or vague request: enter plan mode, plan (subagents allowed), then ask the user to approve before editing.")
for h in hits[:4]:
    print("- hint: " + h)
'
exit 0
