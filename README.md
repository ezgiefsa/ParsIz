# Parsİz — Deniable Operating System

> **TEKNOFEST 2026 — Pardus Development Category**  
> A deniable, privacy-focused operating system layer built on Pardus 23 XFCE

---

## 📌 What is Parsİz?

Parsİz is a deniable operating system architecture built on top of Pardus 23. It allows a single machine to operate in two completely separate modes depending on the password entered at login:

| Login Password | Result |
|----------------|--------|
| Normal password | Standard Pardus desktop — no traces of hidden system |
| Cosmic password | Hidden desktop — files loaded from encrypted LUKS container into RAM |
| Wrong password | Standard authentication failure |

The hidden session leaves **no trace** on disk after shutdown. All data lives in RAM during the session and is synced back to the encrypted container only at shutdown.

> **Note on AI usage:** We designed this system ourselves. AI was used as a research assistant and to accelerate some code blocks. System architecture, integration, and all technical decisions are entirely our own work.

---

## 🏗️ Architecture

```
Login Screen (LightDM + GTK Greeter)
        │
        ▼
   PAM Auth Stack
        │
        ├── Normal Password ──────────────► Standard Pardus Desktop
        │                                   /home/lenovo (real disk)
        │
        └── Cosmic Password
                │
                ▼
         stealthkernel-check.sh
         (Opens LUKS container via cryptsetup)
                │
                ▼
         stealthkernel-pam.sh (session phase)
         ├── Mount LUKS → /mnt/luks_disk
         ├── Create tmpfs (RAM disk) → /mnt/secure_ram
         ├── rsync LUKS contents → RAM
         ├── chown RAM to user
         └── bind mount RAM → /home/lenovo
                │
                ▼
         Hidden Desktop
         (All files in RAM, never written to disk unencrypted)
                │
                ▼
         Shutdown → stealth-shutdown.sh
         ├── Mount LUKS → /mnt/luks_disk
         ├── rsync RAM → LUKS (save all changes)
         ├── umount /home/lenovo
         ├── umount /mnt/secure_ram
         ├── umount /mnt/luks_disk
         ├── cryptsetup close (key wiped from memory)
         └── Clean logs
```

---

## 🔐 Security Model

| Threat | Protection Level | Notes |
|--------|-----------------|-------|
| Remote digital attack | ✅ High | LUKS encrypted container |
| Physical seizure (powered off) | ✅ High | Disk encrypted, key not on disk |
| Physical coercion (rubber-hose) | ✅ High | Normal password opens plausible decoy |
| Forensic disk analysis | ✅ High | LUKS unreadable without cosmic password |
| Cold boot attack | ⚠️ Partial | RAM wipe window ~seconds |
| Suspend / Hibernate | ✅ Disabled | Masked via systemctl |
| Swap | ✅ Disabled | No swap partition |

---

## 📁 Repository Structure

```
Parsİz/
├── README.md                    # This file (English)
├── README.tr.md                 # Turkish documentation
├── install.sh                   # Automated installation script
├── scripts/
│   ├── stealthkernel-check.sh   # PAM auth: opens LUKS if cosmic password
│   ├── stealthkernel-pam.sh     # PAM session: mounts RAM environment
│   └── stealth-shutdown.sh      # Shutdown: syncs RAM → LUKS, cleans traces
├── config/
│   ├── lightdm.conf             # LightDM configuration (GTK greeter)
│   ├── pam.lightdm              # PAM configuration for LightDM
│   └── stealth-sync.service     # systemd service for shutdown sync
├── tests/
│   ├── test_normal_login.md     # Test: normal password login
│   ├── test_hidden_login.md     # Test: cosmic password login
│   ├── test_persistence.md      # Test: data persistence across reboots
│   └── test_security.md         # Test: security controls
└── docs/
    ├── architecture.md          # Detailed architecture documentation
    └── threat_model.md          # Threat model analysis
```

---

## ⚙️ Requirements

- Pardus 23 XFCE (fresh installation recommended)
- `cryptsetup` >= 2.6
- `rsync` >= 3.2
- Minimum 4 GB RAM (tmpfs allocation)
- Minimum 25 GB free disk space (LUKS container)

---

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/ezgiefsa/Parsiz.git
cd Parsiz

# Run installer
sudo bash install.sh
```

The installer will:
1. Create a 20 GB LUKS encrypted container at `/opt/system_data.img`
2. Install PAM authentication scripts
3. Configure LightDM with GTK greeter
4. Set up systemd shutdown sync service
5. Disable swap and hibernate

---

## 🧪 Test Results

| Test | Expected Result | Status |
|------|----------------|--------|
| Normal login | Standard Pardus desktop, no hidden traces | ✅ Pass |
| Cosmic login | Hidden desktop, RAM mounted at `/home/lenovo` | ✅ Pass |
| Wrong password | Authentication failure | ✅ Pass |
| File persistence | Files survive reboot (saved to LUKS on shutdown) | ✅ Pass |
| Normal login after cosmic | Hidden files not visible | ✅ Pass |
| Hibernate attempt | Blocked (masked by systemd) | ✅ Pass |
| Swap check | No swap active | ✅ Pass |
| LUKS integrity | Container unreadable without cosmic password | ✅ Pass |

---

## ⚠️ Important Security Notes

1. **Never use sleep/suspend in hidden session** — only full shutdown (`sudo systemctl poweroff`)
2. **Never use lock screen in hidden session** — logout instead
3. **Cosmic password must never be written down anywhere**
4. **Back up LUKS container periodically** to an external encrypted drive
5. **If cosmic password is forgotten** — data is permanently inaccessible (by design)

---

## 👥 Team

| Name | Role |
|------|------|
| Ebubekir Yılmaz | Developer |
| Ezgi Efsa Güleç | Project Lead & Developer |
| Fatma Zehra Osmanoğlu | Developer |

---

## 📄 License

This project is developed for **TEKNOFEST 2026 — Pardus Development Category**.

---

*Parsİz — Because privacy is not a crime, it's a right.*
