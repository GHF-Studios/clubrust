# 🌍 ClubRust: A Multiplayer World-as-Platform Engine

> A Rust-based, modular, scriptable multiplayer engine built for custom, persistent virtual worlds. Inspired by Club Penguin, Minecraft servers, and a love of deep control.

---

## 🧠 Core Vision
- A multiplayer virtual world where users can chat, walk around, explore dimensions
- Fully browser-based client (Bevy + WASM)
- Structured like an operating system: worlds, users, privileges, scripts
- Built from scratch for growth, extensibility, and fun

---

## 🏗️ High-Level Architecture

### 🔸 Bevy Server Binary (`bevy-server`)
- Hosts ECS worlds ("dimensions")
- Loads world assets from `./worlds/`
- Provides authoritative networking (WebSockets, eventually UDP)
- Evaluates world scripts (Rhai)
- Persists game/user state via SQLite
- Listens on local socket for admin RPC
- Manages backups, hot-reloads, shutdowns

### 🔸 WASM Client (Bevy + Web UI)
- Lives on a static login site served via IPv6
- Once logged in, loads Bevy WASM client
- Connects to server via WebSocket
- Renders 3D/2D world
- All UI is Bevy UI, driven by scripting

### 🔸 Admin Shell Binary (`admin-shell`)
- Local-only REPL
- Connects to server over Unix socket
- Executes privileged Rhai commands
- Cannot be accessed remotely
- Has absolute control over server and dimensions

---

## 📂 Directory Structure
```
clubrust/
├── bevy-server/         # Game server binary
├── admin-shell/         # CLI for local admin
├── client/              # WASM client
├── worlds/              # World-as-asset directories
├── backups/             # Timestamped world/user/db backups
├── logs/                # Optional file-based logs
└── scripts/             # CI/CD and deploy scripts
```

---

## 🔐 Permissions & Scripting

### 📜 Rhai Scripting
- Dimensions are powered by Rhai
- Scripts can spawn entities, respond to events, and create UI
- Scripts are sandboxed by permission context

### 🔑 Permission Model
- Capability-based
- Powers are explicitly granted, not implied by roles
- Server/root can assign any permission
- Scripts and users can only escalate within granted capabilities
- Contexts: `user`, `admin`, `server`

---

## 📦 Deployment Model

### 🧑‍💻 Development Flow
1. Push code to GitHub
2. SSH into server
3. Run `sudo ./bevy-server update`

### 🛠️ Systemd Service
```ini
[Unit]
Description=Bevy Game Server
After=network.target

[Service]
ExecStart=/home/gameuser/game-server/bin/bevy-server
WorkingDirectory=/home/gameuser/game-server
Restart=always
User=gameuser

[Install]
WantedBy=multi-user.target
```

### 📜 Logging
- Logs available via `journalctl -u bevy-server.service -f`
- Optional: logs also written to `./logs/YYYY-MM-DD.log`

---

## 🔁 CI/CD & Backups

### 📥 Updates
- Push code to GitHub
- SSH to server
- Pull & rebuild manually (requires sudo)
- No auto-pulling = safer

### 💾 Backups
- Triggered:
  - On shutdown (default)
  - On schedule (via `cron` or `systemd timer`)
  - On demand via admin command
- Backup contents:
  - `worlds/`
  - SQLite DB
  - Configs
- Stored under:
  - `backups/YYYY-MM-DD_HH-MM-SS/`
  - `backups/latest` symlink

---

## 🧠 Future Possibilities
- Subrealm hosting (modular external worlds)
- Dynamic world editing
- User-generated dimensions (opt-in)
- Modular plugin system via Rhai
- HTML overlay or hybrid UI (if ever needed)

---

## ✅ MVP Feature Set
- [x] Login system
- [x] Persistent user accounts (SQLite)
- [x] Privilege/capability system
- [x] WASM client
- [x] Basic dimension/world with walk/chat
- [x] Rhai scripting sandbox
- [x] Manual CI/CD deploy via SSH
- [x] Scheduled + on-demand backups
- [x] Admin REPL via local socket
