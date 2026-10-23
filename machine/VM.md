# One VM per client/company (VMware) — confidentiality first

```
Host (your PC)                             VM "<CLIENT>" (Ubuntu Server LTS, encrypted)
VS Code + Remote-SSH  ── SSH (key) ──────▶  client repo + ai-kit project kit
browser profile "<CLIENT>" ◀── http ─────   Docker (app, DB, cache), claude, codex, gh (client account)
nothing of the client stored on the host
```
Rule: **the client's code, data and accounts live only in the VM.** The host is only a screen and keyboard.

## 0. Ask the company first
- Which Claude / ChatGPT accounts may be used on their code (company Team/Enterprise, or personal with training off)?
- May real data (DB dumps, customer files) enter the VM? Default: no, anonymised samples only.
- Rules on disk encryption, VPN, backups?

## 1. Create the VM
| Item | Value |
|---|---|
| OS | Ubuntu Server LTS, install OpenSSH server |
| RAM / CPU / disk | 12 GB / 6 vCPU / 120 GB thin (adjust to the host) |
| Network | Adapter 1 NAT (internet). Adapter 2 Host-only (host ↔ VM only: SSH, web app) |
| Encryption | VM Settings › Options › Access Control › Encrypt (strong password in a password manager); host disk encrypted |
| Sharing off | Shared Folders disabled; Guest Isolation: no drag & drop, no copy/paste |
| VM files | not inside OneDrive/Google Drive/Dropbox or any personal cloud backup |

## 2. SSH, key only
1. Host: `ssh-keygen -t ed25519 -f ~/.ssh/<client>_vm` (with passphrase); add the public key to the VM's `~/.ssh/authorized_keys`.
2. VM `/etc/ssh/sshd_config`: `PasswordAuthentication no`, `PermitRootLogin no`; restart ssh.
3. VM firewall: `ufw allow from <host-only subnet> to any port 22`, `ufw enable`.
4. Host `~/.ssh/config`: `Host <client>` with HostName, User, IdentityFile. VS Code › Remote-SSH › connect.

## 3. Inside the VM
`git clone https://github.com/inujustin/ai-kit.git ~/ai-kit` (public, no personal login on a company VM) → `cd ~/ai-kit && claude` → "setup everything".
Then: `git config --global user.name/user.email` = the company identity; `gh auth login` with the company account; `gh auth switch` to make it active.

## 4. Habits
- Separate browser profile for the client, no personal logins in it.
- Never copy client files to the host, USB or personal cloud. Never paste client code or logs into web chat UIs.
- Claude sandbox always on; the kit blocks reading .env, site configs, spreadsheets, dumps, backups.
- Snapshot before risky steps; snapshots hold data too (encrypted with the VM); delete old ones.
- End of project: hand over as the company requires, then delete the VM.
