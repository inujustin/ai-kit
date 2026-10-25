# ai-kit (cá nhân, public)

Bộ setup AI mang đi mọi máy: Claude = não chính, Codex = thợ code + người review. Không chứa dữ liệu công ty/khách.

## Dùng trên máy mới (WSL, VM, máy công ty…)
1. `git clone https://github.com/inujustin/ai-kit.git ~/ai-kit` (repo public, không cần đăng nhập; máy công ty không đăng nhập tài khoản cá nhân)
2. `cd ~/ai-kit && claude`
3. Nói: **"setup everything"**. AI làm theo `SETUP.md`: kiểm máy (`bin/doctor`) → hỏi bạn → cài từng thứ trong `MANIFEST.md`
   (mỗi lệnh có popup giải thích tiếng Việt; lệnh sudo thì AI đưa lệnh, bạn tự gõ trong terminal) → cài kit vào project bạn chọn.
4. Trong mỗi repo dự án: mở `claude` ở đó và nói **"setup the kit for this project"**. AI hỏi bạn để kit ở đâu (**ngoài** repo),
   tạo kit + đăng ký. Từ đó chỉ cần gõ `claude` trong repo: plugin `ai-kit-workflow` tự nạp kit, hook gợi ý skill, chặn git…
   Repo công ty không bao giờ có file nào của kit.
5. Nhiều account: `bin/account add <claude|codex|agy> <tên> <mục đích>` rồi đăng nhập 1 lần. Mở session lead bằng
   `bash ~/ai-kit/bin/ai [tên|mục đích]` (Codex làm não: `--brain codex`). Hết session: `c` = hết quota, chạy tiếp
   cùng cuộc trò chuyện trên account kế tiếp **cùng loại**; `n` = session mới đọc `handoff.md`, session cũ vẫn mở lại được.
6. Nhiều project trên 1 máy: mỗi project 1 team (kit + session lead riêng, mỗi project 1 tab terminal).
   Xem tổng: `python3 ~/ai-kit/bin/projects` (nhánh, chạy dài, ưu tiên, nhóm account).
7. Cập nhật: nói **"update the kit"** → AI `git pull` bản gốc rồi chạy `bin/kit-update` (không đè file bạn đã sửa; hỏi bạn).

```
ai-kit/
├── CLAUDE.md        AI đọc khi mở claude ở đây: "setup everything" làm gì
├── SETUP.md         các bước cài (cho AI)
├── MANIFEST.md      mọi tool/plugin/skill + nguồn + phiên bản đã pin
├── bin/doctor       kiểm máy (chỉ đọc); --leak-check: quét từ khoá công ty trước khi commit
├── machine/         mẫu git identity theo thư mục, hướng dẫn VM
├── project/         kit chép vào từng project (AGENTS.md, CLAUDE.local.md, .ai/, .claude/)
├── plugins/ai-kit-workflow  hook của kit (cài 1 lần mỗi máy, dùng cho mọi project)
├── bin/kit-new, kit-update   tạo kit cho 1 project (ngoài repo) / cập nhật kit an toàn
├── bin/projects             bảng tổng mọi project trên máy (chỉ đọc)
├── bin/account, bin/ai      nhiều account mỗi tool; launcher 1 terminal (đổi account cùng loại, session mới từ handoff)
└── project-exclude.txt   tên file graphify thêm vào .git/info/exclude
```

## Luật an toàn
- Repo này **public**. Không bao giờ chứa tên, email, code, tài liệu của công ty/khách.
- Plugin bên thứ ba đã kiểm tra nằm trong `.claude-plugin/marketplace.json`, khoá theo commit: `claude plugin marketplace add inujustin/ai-kit`.
- AI luôn: giải thích ngắn trong mọi câu hỏi / popup xin quyền; dừng lại hỏi khi luật xung đột; chủ động hỏi luật nào nên thành hook; tự chọn skill và hỏi khi không chắc.
- Từ khoá công ty để chặn lộ nằm **ngoài** repo: `~/.config/ai-kit/leak-words`. AI chạy `bin/doctor --leak-check` trước mỗi commit.
- Phần riêng của từng công ty (luật design system, VM guide có tên dự án…) để trong máy/VM của công ty đó, không đưa vào đây.
- Thêm tool mới: nói "add <tên> to the kit"; AI kiểm nguồn chính chủ, hỏi bạn, rồi ghi vào MANIFEST.md.

## Gỡ
Một project: xoá thư mục kit của nó, dòng của nó trong `~/.config/ai-kit/projects.tsv`, `.git/hooks/pre-push` (chỉ kit cũ mới có), các dòng graphify trong `.git/info/exclude`.
Trên máy: `claude plugin uninstall <tên>`, `uv tool uninstall <tên>`, `npm uninstall -g <tên>`, `graphify uninstall`.
