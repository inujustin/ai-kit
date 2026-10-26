#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit|NotebookEdit|Bash) and SessionEnd: one lead session per project.
# Two Claude sessions changing one checkout overwrite each other's half-done work. The session working in a repo with a
# kit is that project's lead: its tool calls refresh $KIT/.ai/run/lead ("<owner> <epoch>", under flock, replaced
# atomically). bin/fresh holds the same lease as "fresh-<pid>" while its run goes. Then:
#   - another session in that repo, while the lead is alive (refreshed within AI_LEAD_TTL_MIN, default 30 min), may only
#     read: edits and every Bash command that is not one plain read-only command get a popup (decision "ask"; with
#     --permission-prompts none that is a refusal);
#   - a session opened in another folder that edits a kit project's files, or runs a non-read-only Bash command whose
#     paths (absolute, relative, cd/-C targets) reach them, gets the same popup, unless that kit is open (`run open`)
#     and has no live lead.
# Agents the lead starts (bin/fresh, dispatch, gate via claude_session) carry AI_KIT_DELEGATE=<their kit>: they pass
# inside that project only; any other project is checked like above. Subagents share the lead's session id.
# shortcut: paths built at run time (variables, scripts, python -c) are not seen; the Bash sandbox is the real boundary.
here="$(dirname "$0")"
input=$(cat)
read_json() { printf '%s' "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print($1)" 2>/dev/null; }
sid=$(read_json 'd.get("session_id","")')
cwd=$(read_json 'd.get("cwd","")'); cwd="${cwd:-$PWD}"
[ -n "$sid" ] || exit 0
ttl=$(( ${AI_LEAD_TTL_MIN:-30} * 60 )); now=$(date +%s)
mykit="$(bash "$here/kit-resolve.sh" "$cwd" 2>/dev/null)"
delegate="${AI_KIT_DELEGATE:-}"; [ "$delegate" = 1 ] && delegate=""   # old unscoped value: no exemption

# live_other <kit>: prints the owner when a different, recently active session (or bin/fresh run) leads that kit
live_other() {
  local f="$1/.ai/run/lead" who at
  [ -f "$f" ] || return 1
  read -r who at 2>/dev/null < "$f"
  [ -n "$who" ] && [ "$who" != "$sid" ] && [ $(( now - ${at:-0} )) -lt "$ttl" ] && { echo "$who"; return 0; }
  return 1
}
# claim <kit>: become (or stay) the lead unless someone else leads now; prints the other owner when refused
claim() {
  local f="$1/.ai/run/lead"
  mkdir -p "$1/.ai/run"
  (
    flock 7
    if o="$(live_other "$1")"; then echo "$o"; exit 0; fi
    echo "$sid $now" > "$f.tmp.$$" && mv "$f.tmp.$$" "$f"
  ) 7>"$f.lock"
}
ask() {
  python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": sys.argv[1]}}))' "$1"
  exit 0
}

if [ "${1:-}" = end ]; then
  [ -n "$mykit" ] || exit 0
  f="$mykit/.ai/run/lead"
  ( flock 7; [ "$(cut -d' ' -f1 "$f" 2>/dev/null)" = "$sid" ] && rm -f "$f" ) 7>"$f.lock" 2>/dev/null
  exit 0
fi

tool=$(read_json 'd.get("tool_name","")')
other=""; [ -n "$mykit" ] && [ -z "$delegate" ] && other="$(claim "$mykit")"

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    f=$(read_json 'd.get("tool_input",{}).get("file_path") or d.get("tool_input",{}).get("notebook_path") or ""')
    [ -n "$f" ] || exit 0
    case "$f" in /*) ;; *) f="$cwd/$f" ;; esac
    targets="$f"; what="sửa $f" ;;
  Bash)
    cmd=$(read_json 'd.get("tool_input",{}).get("command","")')
    # "RO" = one plain read-only command; else every path the command names, resolved against cwd (one per line)
    targets="$(printf '%s' "$cmd" | CWD="$cwd" python3 -c '
import os, re, shlex, sys
c, cwd = sys.stdin.read(), os.environ["CWD"]
plain = re.sub(r"\s2>\s*/dev/null\s*$", "", c.strip())
try:
    w = shlex.split(plain)
except ValueError:
    w = []
READERS = {"ls", "cat", "head", "tail", "wc", "grep", "pwd", "stat", "which", "echo"}   # none can write a file
GIT_READ = {"status", "log", "show", "diff", "rev-parse", "ls-files", "blame"}
def readonly(w):
    if not w or re.search(r"[&;|<>$`()\n\\]", plain): return False
    if w[0] in READERS: return True
    if w[0] == "git":
        a = w[1:]
        if a[:1] == ["-C"]: a = a[2:]
        bad = any(x.startswith(("--output", "-o", "--ext-diff", "--textconv")) for x in a)
        return bool(a) and not bad and (a[0] in GIT_READ or a[:2] == ["branch", "--show-current"])
    if len(w) == 3 and re.search(r"/\.ai/bin/run$", w[1]) and w[0] == "python3" and w[2] in ("status", "board"): return True
    return len(w) == 2 and w[0] == "bash" and bool(re.search(r"/\.ai/bin/(status|test-scan)$", w[1]))
if readonly(w):
    print("RO"); sys.exit(0)
try:
    toks = shlex.split(c.replace(";", " ; ").replace("&&", " && ").replace("|", " | "))
except ValueError:
    toks = c.split()
out = [cwd]
for i, t in enumerate(toks):
    if (i and toks[i - 1] in ("cd", "-C", "pushd")) or "/" in t or t.startswith("~"):
        t = t.split("=", 1)[-1] if t.startswith("-") else t
        if not t or t.startswith("-") or "://" in t: continue
        out.append(os.path.normpath(os.path.join(cwd, os.path.expanduser(t))))
print("\n".join(out))')"
    [ "$targets" = RO ] && exit 0
    what="chạy lệnh: ${cmd:0:160}" ;;
  *) exit 0 ;;
esac

seen=""
while IFS= read -r t; do
  [ -n "$t" ] || continue
  d="$t"; [ -d "$d" ] || d="$(dirname "$d")"; while [ ! -d "$d" ]; do d="$(dirname "$d")"; done
  tkit="$(bash "$here/kit-resolve.sh" "$d" 2>/dev/null)" || continue
  case " $seen " in *" $tkit "*) continue ;; esac; seen="$seen $tkit"
  [ -n "$delegate" ] && [ "$tkit" = "$delegate" ] && continue   # an agent the lead started, in its own project
  troot="$(dirname "$(git -C "$d" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")"
  if [ "$tkit" = "$mykit" ] && [ -z "$delegate" ]; then
    [ -n "$other" ] && ask "⚠ MỘT PROJECT, HAI SESSION: ${other:0:14} đang là lead của project này ($troot) và vừa hoạt động trong ${AI_LEAD_TTL_MIN:-30} phút qua. Session này chỉ nên đọc. AI muốn $what, dễ ghi đè việc đang làm dở của lead. Chọn No và để lead làm (hoặc dừng nó trước); chọn Yes chỉ khi bạn chắc lead đã dừng. Hoàn tác: git diff / git checkout file đó."
    continue
  fi
  if lead="$(live_other "$tkit")"; then
    ask "⚠ FILE CỦA PROJECT KHÁC: project $troot đang có lead ${lead:0:14}. Session này (mở ở $cwd) không phải team của nó. AI muốn $what, dễ ghi đè việc đang làm dở. Chọn No, rồi làm việc này trong session của project đó; chọn Yes chỉ khi chính bạn muốn làm từ đây. Hoàn tác: git diff / git checkout file đó."
  fi
  bash "$here/open-state.sh" "$tkit" >/dev/null && continue
  ask "⚠ FILE CỦA PROJECT KHÁC: $troot có kit riêng ($tkit), nhưng session này mở ở $cwd nên không nạp luật của kit đó (guard, mode.conf, LESSONS). AI muốn $what. Chọn No, rồi mở claude trong $troot để làm; chọn Yes chỉ khi chính bạn muốn làm từ đây. Hoàn tác: git diff / git checkout file đó."
done <<< "$targets"
exit 0
