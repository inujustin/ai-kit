# ai-kit (cá nhân, public)

Bộ setup AI mang đi mọi máy: Claude = não chính, Codex = thợ code + người review. Không chứa dữ liệu công ty/khách.

## Dùng trên máy mới (WSL, VM, máy công ty…)
1. `git clone https://github.com/inujustin/ai-kit.git ~/ai-kit` (repo public, không cần đăng nhập; máy công ty không đăng nhập tài khoản cá nhân)
2. `cd ~/ai-kit && claude`
3. Nói: **"setup everything"**. AI làm theo `SETUP.md`: kiểm máy (`bin/doctor`) → hỏi bạn → cài từng thứ trong `MANIFEST.md`
   (mỗi lệnh có popup giải thích tiếng Việt; lệnh sudo hiện cửa sổ nhập mật khẩu hoặc đưa bạn tự gõ) → cài kit vào project bạn chọn.
4. Trong mỗi repo dự án: mở `claude` ở đó và nói **"setup the kit for this project"** → có hook gợi ý skill, chặn git, nhắc luật…
5. Gửi ảnh chụp cho AI (Remote-SSH): mở `~/shots/paste.md` trong VS Code, Ctrl+V, rồi bảo AI xem `~/shots/`.

```
ai-kit/
├── CLAUDE.md        AI đọc khi mở claude ở đây: "setup everything" làm gì
├── SETUP.md         các bước cài (cho AI)
├── MANIFEST.md      mọi tool/plugin/skill + nguồn + phiên bản đã pin
├── bin/doctor       kiểm máy (chỉ đọc); --leak-check: quét từ khoá công ty trước khi commit
├── bin/askpass      cửa sổ nhập mật khẩu sudo
├── machine/         mẫu git identity theo thư mục, hướng dẫn VM
├── project/         kit chép vào từng project (AGENTS.md, CLAUDE.local.md, .ai/, .claude/)
└── project-exclude.txt   dòng thêm vào .git/info/exclude của project
```

## Luật an toàn
- Repo này **public**. Không bao giờ chứa tên, email, code, tài liệu của công ty/khách.
- Plugin bên thứ ba đã kiểm tra nằm trong `.claude-plugin/marketplace.json`, khoá theo commit: `claude plugin marketplace add inujustin/ai-kit`.
- AI luôn: giải thích ngắn trong mọi câu hỏi / popup xin quyền; dừng lại hỏi khi luật xung đột; chủ động hỏi luật nào nên thành hook; tự chọn skill và hỏi khi không chắc.
- Từ khoá công ty để chặn lộ nằm **ngoài** repo: `~/.config/ai-kit/leak-words`. AI chạy `bin/doctor --leak-check` trước mỗi commit.
- Phần riêng của từng công ty (luật design system, VM guide có tên dự án…) để trong máy/VM của công ty đó, không đưa vào đây.
- Thêm tool mới: nói "add <tên> to the kit"; AI kiểm nguồn chính chủ, hỏi bạn, rồi ghi vào MANIFEST.md.

## Gỡ
Trong project: xoá `AGENTS.md`, `CLAUDE.local.md`, `.ai/`, `.worktrees/`, `.claude/settings.local.json`, `.git/hooks/pre-push`, các dòng trong `.git/info/exclude`.
Trên máy: `claude plugin uninstall <tên>`, `uv tool uninstall <tên>`, `npm uninstall -g <tên>`, `graphify uninstall`.
