#!/usr/bin/env bash
# PreToolUse: anything outside the workspace is dangerous. Workspace = the repo of the current folder, its registered kit,
# the session's project folder, the dirs the user allowed in ~/.claude/settings.json (additionalDirectories) and the
# session temp dir. Outside that, and on WSL the Windows side (/mnt/<drive>, \\wsl$, *.exe interop), nothing is
# blocked silently and nothing is allowed silently: a permission popup (decision "ask", also in auto mode) explains in
# Vietnamese what, where, why it is risky, what Yes does and how to undo. Bulk deletes/moves there are denied.
here="$(dirname "$0")"
input=$(cat)
cwd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null); cwd="${cwd:-$PWD}"
roots=()
r="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" && roots+=("$(dirname "$r")")
k="$(bash "$here/kit-resolve.sh" "$cwd" 2>/dev/null)" && roots+=("$k")
[ -n "${CLAUDE_PROJECT_DIR:-}" ] && roots+=("$CLAUDE_PROJECT_DIR")
roots+=("$cwd" "${TMPDIR:-/tmp/claude-$(id -u)}" "/tmp/claude-$(id -u)")
wsl=no; { grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; } && wsl=yes
printf '%s' "$input" | WSL="$wsl" ROOTS="$(printf '%s\n' "${roots[@]}")" HOME_DIR="$HOME" python3 -c '
import json, os, re, sys
d = json.load(sys.stdin)
tool, ti = d.get("tool_name", ""), d.get("tool_input", {}) or {}
home = os.environ["HOME_DIR"]; wsl = os.environ["WSL"] == "yes"
roots = [os.path.realpath(r) for r in os.environ["ROOTS"].split("\n") if r]
try:
    roots += [os.path.realpath(os.path.expanduser(p)) for p in json.load(open(home + "/.claude/settings.json")).get("permissions", {}).get("additionalDirectories", [])]
except Exception:
    pass
SAFE = ("/dev/", "/proc/self", "/usr/bin/", "/bin/", "/usr/local/bin/", "/usr/lib/", "/usr/share/", "/lib/", "/etc/os-release")
def inside(p):
    p = os.path.realpath(os.path.expanduser(p))
    return any(p == r or p.startswith(r.rstrip("/") + "/") for r in roots) or p.startswith(SAFE)
def is_win(p):
    return bool(re.match(r"/mnt/[a-z](/|$)", p, re.I)) or p.startswith("\\\\wsl")
def out(decision, reason):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": decision, "permissionDecisionReason": reason}}))
    sys.exit(0)
def explain(where, what, risk):
    return ("⚠ NGOÀI WORKSPACE (" + where + "). AI muốn: " + what + ". Rủi ro: " + risk +
            ". Chọn Yes chỉ khi chính bạn yêu cầu việc này; chọn No thì AI phải hỏi lại bạn bằng popup và giải thích vì sao cần."
            " Hoàn tác: việc đọc thì không đổi gì; việc ghi/sửa ở ngoài workspace có thể KHÔNG hoàn tác được.")
BULK = re.compile(r"\brm\s+-[a-z]*[rf]|\brmdir\b|\bfind\b.*-delete|\bmv\b|\bshred\b|\btruncate\b|\brsync\b.*--delete|\bchmod\s+-R|\bchown\s+-R", re.I)
if tool == "Bash":
    cmd = ti.get("command", "")
    paths = re.findall(r"(?:(?<=[\s\"\x27=:(])|^)((?:~|/)[^\s\"\x27;|&)<>]*)", cmd)
    win = [p for p in paths if is_win(p)] + re.findall(r"\\\\wsl[^\s]*", cmd)
    outside = [p for p in paths if p not in win and not inside(p)]
    exe = wsl and re.search(r"(^|[\s;&|(/])[\w.-]+\.exe\b|\b(powershell|pwsh|cmd)(\.exe)?\b|\bwslview\b|\bexplorer\b", cmd, re.I)
    if (win or outside) and BULK.search(cmd):
        out("deny", "ai-kit guard-outside: xoá/di chuyển/đổi quyền hàng loạt ngoài workspace (" + ", ".join((win + outside)[:3]) + "). AI không tự chạy: đưa người dùng đúng 1 dòng lệnh, giải thích nó xoá/đổi gì và không hoàn tác được, để họ tự gõ nếu muốn.")
    if win:
        out("ask", explain("ổ Windows: " + ", ".join(win[:3]), "chạy lệnh: " + cmd[:180], "đây là dữ liệu Windows ngoài lớp WSL; lệnh có thể đọc file cá nhân hoặc sửa file Windows"))
    if exe:
        out("ask", explain("chương trình Windows", "chạy: " + cmd[:180], "WSL gọi thẳng chương trình Windows, chạy với quyền của bạn trên Windows, ngoài sandbox của Claude"))
    if outside:
        out("ask", explain(", ".join(outside[:3]), "chạy lệnh: " + cmd[:180], "đường dẫn nằm ngoài repo đang làm và kit của nó (cấu hình, dữ liệu cá nhân hoặc dự án khác)"))
    sys.exit(0)
p = ti.get("file_path") or ti.get("notebook_path") or ti.get("path") or ""
if p and (is_win(p) or not inside(p)):
    verb = "đọc/tìm trong" if tool in ("Read", "Glob", "Grep") else "SỬA/GHI"
    risk = "dữ liệu Windows ngoài lớp WSL" if is_win(p) else "file nằm ngoài repo đang làm và kit của nó (có thể là cấu hình, secret, dữ liệu cá nhân hoặc dự án khác)"
    out("ask", explain(p, verb + " " + p, risk))
'
exit 0
