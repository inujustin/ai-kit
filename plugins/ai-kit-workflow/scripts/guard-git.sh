#!/usr/bin/env bash
# PreToolUse(Bash): git and remote commands follow the project's work profile ($KIT/.ai/mode.conf: BRANCHES, REMOTE,
# PROTECTED_BRANCHES). Nothing risky runs in silence and nothing is locked for good: a permission popup (decision
# "ask", also in auto mode) explains in Vietnamese what the command does, what it changes, the risk and how to undo.
#   always refused: force-push, push --all/--mirror, push to a protected branch, kit/plan/ticket files in a commit,
#                   commits on a protected branch (kit repos), commit subjects that break commit-style.conf (kit repos)
#   remote (push, pull, fetch, remote, clone, gh ...): REMOTE=ask -> popup; feature -> feature-branch push and fetch
#                   pass, the rest popup; never -> refused (the AI gives the user one `!` line)
#   branches (switch, checkout <branch>, checkout -b, branch <new>/-d/-m): BRANCHES=auto passes local branches matching
#                   AUTO_BRANCH_ERE on a clean tree; everything else popup
#   always popup:   reset --hard, clean -f, rebase, merge, stash drop/clear, worktree add (unless PARALLEL=worktree and
#                   the worktree goes in $KIT/worktrees/)
#   push for one run: $KIT/.ai/run/allow-push (created only after the user said "push by yourself" for this run; ends
#                   with the run or after 24 h) makes REMOTE=feature for that time.
# Agreed cases get an explicit "allow" (so an overnight run does not stop at a popup); deny rules in settings still win.
# Repos without a registered kit get the defaults (ask for branches and remote) and no commit rules.
here="$(dirname "$0")"
input=$(cat)
cwd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null); cwd="${cwd:-$PWD}"
printf '%s' "$input" | grep -qE '(^|[^[:alnum:]_-])(git|gh)([[:space:]]|\\"|$)' || exit 0
kit="$(bash "$here/kit-resolve.sh" "$cwd" 2>/dev/null)" || kit=""
BRANCHES=ask; REMOTE=ask; PARALLEL=no; AUTO_BRANCH_ERE='^(feat|fix|chore|refactor|docs|test)/'
PROTECTED_BRANCHES='^(main|master|develop|dev|release.*|production|staging)$'
SUBJECT_ERE=''; BAD_SUBJECT_ERE=''; COMMIT_STYLE_SOURCE=''
# shellcheck source=/dev/null
[ -n "$kit" ] && [ -f "$kit/.ai/mode.conf" ] && . "$kit/.ai/mode.conf"
# shellcheck source=/dev/null
[ -n "$kit" ] && [ -f "$kit/.ai/commit-style.conf" ] && . "$kit/.ai/commit-style.conf"
ap="$kit/.ai/run/allow-push"
if [ -n "$kit" ] && [ -f "$ap" ] && [ "$REMOTE" != never ]; then
  if [ $(( $(date +%s) - $(stat -c %Y "$ap") )) -lt 86400 ]; then REMOTE=feature; else rm -f "$ap"; fi
fi
printf '%s' "$input" | KIT="$kit" CWD="$cwd" BRANCHES="$BRANCHES" REMOTE="$REMOTE" PARALLEL="$PARALLEL" AUTO_ERE="$AUTO_BRANCH_ERE" \
  PROT="$PROTECTED_BRANCHES" SUBJ="$SUBJECT_ERE" BADSUBJ="$BAD_SUBJECT_ERE" STYLE="$COMMIT_STYLE_SOURCE" python3 -c '
import json, os, re, shlex, subprocess, sys
E = os.environ
cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")
kit, cwd = E["KIT"], E["CWD"]
prot = re.compile(E["PROT"])
def git(d, *a):
    try: return subprocess.run(["git", "-C", d, *a], capture_output=True, text=True).stdout.strip()
    except Exception: return ""
def out(decision, reason):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": decision, "permissionDecisionReason": reason}}))
    sys.exit(0)
def block(why):
    print("Blocked by ai-kit guard-git: " + why, file=sys.stderr); sys.exit(2)
asks, allows = [], []
def ask(what, change, risk, undo):
    asks.append("⚠ GIT: " + what + ". Thay đổi: " + change + ". Rủi ro: " + risk + ". Hoàn tác: " + undo + ".")

# Split into simple commands; track `cd` so -C-less commands know their folder.
here = cwd
for seg in re.split(r"&&|\|\||;|\||\n", cmd):
    try: t = shlex.split(seg)
    except ValueError: t = seg.split()
    if not t: continue
    if t[0] == "cd" and len(t) > 1:
        here = os.path.join(here, os.path.expanduser(t[1])); continue
    while t and re.match(r"^[A-Z_]+=", t[0]): t = t[1:]
    if not t or t[0] not in ("git", "gh"): continue
    d = here
    if t[0] == "gh":
        if E["REMOTE"] == "never": block("REMOTE=never for this project: give the user one copy-ready `! gh ...` line with what it does, do not run it.")
        ask("lệnh GitHub `" + " ".join(t)[:150] + "`", "đọc hoặc ghi lên GitHub (PR, issue, release, repo...), người khác có thể thấy", "ghi lên GitHub là công khai với team/người xem repo, có thể bị lưu lại dù xoá sau", "PR/issue/comment phải tự đóng hoặc xoá trên GitHub; đọc thì không đổi gì")
        continue
    a = t[1:]
    while a and a[0] in ("-C", "-c"):
        if a[0] == "-C" and len(a) > 1: d = os.path.join(d, os.path.expanduser(a[1]))
        a = a[2:]
    if not a: continue
    sub, rest = a[0], a[1:]
    pos = [x for x in rest if not x.startswith("-")]
    branch = git(d, "branch", "--show-current")
    dirty = len([l for l in git(d, "status", "--porcelain").splitlines() if l])
    where = "đang ở nhánh " + (branch or "(detached)") + (", có " + str(dirty) + " file chưa commit" if dirty else ", cây sạch")

    if sub == "push":
        if any(x in ("-f", "--force", "--force-with-lease") or x.startswith("--force") or x.startswith("+") for x in rest): block("no force-push.")
        if any(x in ("--all", "--mirror", "--tags") for x in rest): block("push one named branch only.")
        refs = pos[1:] if len(pos) > 1 else [branch]
        dst = [r.split(":")[-1].replace("refs/heads/", "") for r in refs if r]
        if any(prot.search(x) for x in dst if x != "HEAD") or (any(r.split(":")[-1] == "HEAD" for r in refs) and prot.search(branch or "")):
            block("never push straight to a protected branch (" + ", ".join(dst) + "); push the feature branch and open a PR (ask the user).")
        if E["REMOTE"] == "never": block("REMOTE=never for this project: give the user one copy-ready `! git push ...` line instead.")
        if E["REMOTE"] == "feature" and len(dst) == 1:
            allows.append("push " + dst[0] + " (REMOTE=feature)"); continue
        ask("push " + ", ".join(dst) + " lên remote " + (pos[0] if pos else "mặc định") + " (" + where + ")", "commit local được gửi lên server, đồng nghiệp/CI thấy được", "code rời khỏi máy này; nếu có secret hay dữ liệu khách trong commit thì đã lộ", "xoá nhánh trên remote (git push <remote> --delete <nhánh>) nhưng người khác có thể đã kéo về")
    elif sub in ("pull", "fetch", "remote", "ls-remote", "clone", "submodule"):
        if E["REMOTE"] == "never": block("REMOTE=never for this project: give the user one copy-ready `! git " + sub + " ...` line instead.")
        if E["REMOTE"] == "feature" and sub == "fetch":
            allows.append("fetch (REMOTE=feature)"); continue
        if sub == "remote" and (not pos or pos[0] in ("-v", "show", "get-url")): continue
        info = {"pull": ("kéo code từ remote và MERGE/REBASE vào nhánh " + (branch or "?"), "có thể gây conflict hoặc đổi file đang làm", "git reset --hard ORIG_HEAD (mất thay đổi chưa commit nếu có)"),
                "fetch": ("tải ref mới từ remote, không đổi file đang làm", "chỉ dùng mạng, gần như không rủi ro", "không cần"),
                "remote": ("đổi danh sách remote (thêm/xoá/đổi URL)", "push sau đó có thể đi tới server khác", "git remote remove/set-url lại"),
                "ls-remote": ("đọc danh sách nhánh trên remote", "chỉ dùng mạng", "không cần"),
                "clone": ("tạo THÊM một bản sao repo trên máy (tốn dung lượng)", "kit dặn làm thẳng trong repo; bản sao dễ lệch code và tốn tài nguyên", "xoá thư mục vừa clone"),
                "submodule": ("đổi/kéo submodule từ remote", "có thể đổi code phụ thuộc", "git submodule update về commit cũ")}[sub]
        ask("git " + sub + " (" + where + ")", info[0], info[1], info[2])
    elif sub in ("switch", "checkout") and "--" not in rest:
        new = any(x in ("-b", "-B", "-c", "-C", "--orphan") for x in rest)
        target = pos[-1] if pos else ""
        if not target or (sub == "checkout" and not new and os.path.exists(os.path.join(d, target)) and not git(d, "rev-parse", "-q", "--verify", "refs/heads/" + target)): continue
        if E["BRANCHES"] == "auto" and not dirty and re.search(E["AUTO_ERE"], target):
            allows.append(sub + " " + target + " (BRANCHES=auto)"); continue
        ask(("tạo nhánh mới " if new else "chuyển sang nhánh ") + target + " (" + where + ")", "file trong repo đổi theo nhánh đích" + ("; các file chưa commit sẽ đi theo hoặc làm lệnh lỗi" if dirty else ""), "làm nhầm nhánh thì commit sau đó vào sai chỗ" + ("; file chưa commit có thể bị lẫn" if dirty else ""), "git switch " + (branch or "<nhánh cũ>") + " để quay lại")
    elif sub == "branch":
        if any(x in ("-d", "-D", "--delete") for x in rest):
            ask("XOÁ nhánh local " + ", ".join(pos), "nhánh biến mất khỏi máy", "-D xoá cả khi chưa merge: commit chỉ còn trong reflog ~90 ngày", "git branch <tên> <sha> (lấy sha từ git reflog)")
        elif any(x in ("-m", "-M", "--move") for x in rest):
            ask("đổi tên nhánh " + " -> ".join(pos), "tên nhánh local đổi", "nhánh remote/PR cũ không theo tên mới", "git branch -m <tên mới> <tên cũ>")
        elif pos and not any(x in ("-a", "-r", "--list", "-v", "-vv", "--contains", "--merged", "--no-merged", "--show-current") for x in rest):
            if E["BRANCHES"] == "auto" and re.search(E["AUTO_ERE"], pos[0]):
                allows.append("branch " + pos[0] + " (BRANCHES=auto)")
            else:
                ask("tạo nhánh local " + pos[0] + " (" + where + ")", "thêm một nhánh, không đổi file", "thấp", "git branch -d " + pos[0])
    elif sub == "reset" and "--hard" in rest:
        ask("git reset --hard (" + where + ")", "đưa nhánh và file về commit khác", "MẤT mọi thay đổi chưa commit, KHÔNG hoàn tác được", "commit đã có thì lấy lại qua git reflog; file chưa commit thì không")
    elif sub == "clean" and any(x.startswith("-") and "f" in x for x in rest):
        ask("git clean (" + where + ")", "xoá file chưa được git theo dõi", "file xoá KHÔNG lấy lại được", "không hoàn tác được")
    elif sub in ("rebase", "merge"):
        ask("git " + sub + " " + " ".join(pos) + " (" + where + ")", "viết lại lịch sử" if sub == "rebase" else "gộp nhánh khác vào " + (branch or "?"), "có thể conflict; rebase đổi sha của commit đã chia sẻ", "git reset --hard ORIG_HEAD ngay sau đó")
    elif sub == "stash" and pos[:1] and pos[0] in ("drop", "clear"):
        ask("git stash " + pos[0], "xoá thay đổi đã cất trong stash", "khó lấy lại", "chỉ cứu được qua git fsck nếu may")
    elif sub == "worktree" and pos[:1] == ["add"] and E["PARALLEL"] == "worktree" and kit and len(pos) > 1 and os.path.realpath(os.path.join(d, pos[1])).startswith(os.path.realpath(kit) + "/worktrees/"):
        allows.append("worktree add in the kit (PARALLEL=worktree)")
    elif sub == "worktree" and pos[:1] == ["add"]:
        ask("git worktree add (tạo thêm một thư mục làm việc của repo)", "thêm thư mục và nhánh", "kit dặn làm thẳng trong repo; thêm bản sao tốn dung lượng và dễ quên dọn", "git worktree remove <thư mục>")
    elif sub in ("commit", "cherry-pick", "revert") and kit:
        if prot.search(branch or ""): block("never commit on protected branch \"" + branch + "\". Ask the user (AskUserQuestion) which feature branch to use.")
        if sub == "commit":
            staged = git(d, "diff", "--cached", "--name-only").splitlines()
            leak = [f for f in staged if re.search(r"^(\.ai/|CLAUDE\.local\.md$|\.claude/plans/)|(^|/)tickets/T[0-9]+[^/]*\.md$", f)][:5]
            if leak: block("these staged files look like ai-kit, ticket or plan files, which never enter the repo: " + ", ".join(leak) + ". Unstage them (git restore --staged <file>).")
            m = [rest[i + 1] for i, x in enumerate(rest[:-1]) if x == "-m"]
            if m and E["SUBJ"]:
                s = m[0].splitlines()[0]
                if not re.search(E["SUBJ"], s): block("commit subject \"" + s + "\" does not match $KIT/.ai/commit-style.conf (" + E["STYLE"] + "). Say the behaviour a teammate can observe.")
                if E["BADSUBJ"] and re.search(E["BADSUBJ"], s, re.I): block("commit subject \"" + s + "\" looks like wip/fixup/typo; describe the step.")
if allows and not asks:
    out("allow", "ai-kit guard-git: agreed in this project\x27s mode.conf: " + "; ".join(allows))
if asks:
    out("ask", " | ".join(asks)[:1500] + " Chọn Yes chỉ khi việc này đúng ý bạn; chọn No thì AI phải hỏi lại bằng popup và giải thích vì sao cần.")
'
