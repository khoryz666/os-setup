# OS Setup

Setup notes for two machines: **Windows 11** and **Linux Mint**. Each step is
tagged:

- **(Manual)** — interactive/GUI, or destructive enough that it should not be
  scripted (partitioning, writing a USB drive, clicking through an installer).
- **(Scripted)** — has a script in [`scripts/`](scripts/) you run yourself.

Nothing here runs automatically end-to-end — every script is meant to be
inspected and run by hand, one stage at a time.

---

## Windows 11

### 1. Run WinUtil (Manual)

In an elevated PowerShell:

```powershell
irm https://christitus.com/win | iex
```

Launches Chris Titus Tech's WinUtil — used below for debloating and for
building a custom Win11 ISO.

### 2–4. Build a debloated Win11 ISO (Manual, GUI)

Inside WinUtil:

2. Open the **Win11 ISO Creator** ("MicroWin") tab.
3. Use its built-in fetcher to download an official Win11 ISO from Microsoft.
4. Load that ISO into MicroWin and apply the debloat/customization options.

Output is a custom `.iso`. This is interactive by design (you're choosing
which components/apps to strip) so it isn't scripted.

### 5. Create a bootable USB drive (Manual)

Write the ISO produced in step 4 to a USB drive, WinUtil will handle it

### 6. Install Windows from the USB (Manual)

Boot from the USB and run through the Windows installer as usual.

### 7. Windows Update + drivers (Manual)

Settings → Windows Update → check for updates, install everything (including
"Optional updates" / driver updates). Repeat until it reports up to date —
debloated images sometimes need a couple of passes.

While you're in Settings: also add the **Pinyin** input method (Settings →
Time & language → Language & region → add Chinese (Simplified) →
**Language options** → add the Microsoft Pinyin keyboard) so Chinese input
is available alongside the Mint setup's Pinyin step below.

### 8. Create a separate partition for WSL (Manual, destructive)

Use Disk Management (`diskmgmt.msc`) — shrink an existing volume and create a
new simple volume with its own drive letter (e.g. `D:`). This is left manual
on purpose: resizing partitions is destructive if done wrong, and the target
drive letter/size is a judgment call, not something to hardcode into a script.

### 9. Install WSL onto that partition (Scripted, 2 steps)

WSL always installs its distro registration to the default location first;
then it's moved onto the new partition:

```powershell
wsl --install -d Ubuntu
```

Reboot if prompted, finish the Ubuntu first-run (create the Linux user), then
move the distro's virtual disk onto the partition created in step 8:

```powershell
.\scripts\windows\wsl-move-to-partition.ps1 -DistroName Ubuntu -TargetDrive D:\WSL
```

See [`scripts/windows/wsl-move-to-partition.ps1`](scripts/windows/wsl-move-to-partition.ps1)
— it's just `wsl --export` → `wsl --unregister` → `wsl --import` into the new
location.

**Tip:** to browse/`cd` into the WSL filesystem from a normal Windows
PowerShell/cmd prompt (without entering the WSL shell):

```powershell
cd \\wsl.localhost\Ubuntu\home\<username>
```

### 10. Bootstrap tools inside WSL (Scripted)

Inside the Ubuntu WSL shell (`wsl -d Ubuntu`), run:

```bash
./scripts/wsl/bootstrap.sh
```

[`scripts/wsl/bootstrap.sh`](scripts/wsl/bootstrap.sh) installs, in order:

- Nix (official multi-user installer, `--daemon`)
- git
- an `ed25519` SSH key, adds it to `ssh-agent`, and pauses so you can paste
  the public key into <https://github.com/settings/keys>
- git identity (`user.name`, `user.email`, `init.defaultBranch main`)
- [fresh IDE](https://github.com/sinelaw/fresh) (`curl ... | sh`)
- podman

### 11. Install Scoop (Scripted)

In a **regular, non-admin** PowerShell (Scoop refuses to run elevated):

```powershell
.\scripts\windows\install-scoop.ps1
```

[`scripts/windows/install-scoop.ps1`](scripts/windows/install-scoop.ps1) sets
the execution policy for the current user and installs
[Scoop](https://scoop.sh/).

### 12. Desktop apps + light theme (Scripted)

Back in an elevated Windows PowerShell:

```powershell
.\scripts\windows\post-install-apps.ps1
```

[`scripts/windows/post-install-apps.ps1`](scripts/windows/post-install-apps.ps1)
runs `winget install` for:

| App     | winget id          |
|---------|---------------------|
| Firefox | `Mozilla.Firefox`   |
| Chrome  | `Google.Chrome`     |
| Discord | `Discord.Discord`   |
| WhatsApp| `WhatsApp` |
| Nuclear | `nukeop.nuclear`    |
| Obsidian| `Obsidian.Obsidian` |

...then flips Windows to the light theme (apps + system) via the
`Personalize` registry keys. Sign out/in afterwards for it to fully apply.

---

## Linux Mint

### 1. Download ISO + create bootable USB (Manual)

Download the Mint ISO from <https://linuxmint.com/download.php>, write it to
USB with [Rufus](https://rufus.ie/)/`dd`/Ventoy. Same reasoning as the
Windows USB step — writing raw disks isn't something to hand to a script.

### 2. Install Linux Mint (Manual)

Boot the USB, run the installer.

### 3. Chinese input (Pinyin) (Manual)

Settings → **Languages** (or **Input Method**) → install/enable IBus, add
the Pinyin input method (`ibus-libpinyin` or `fcitx` + `fcitx-pinyin`
depending on which input framework Mint offers), then log out/in and add the
input source via the IBus applet. GUI/login-session-dependent, so left
manual.

### 4. Fractional scaling — 150% (Manual)

Cinnamon's fractional scaling is an experimental per-session toggle:
**System Settings → Display** → enable fractional scaling → set 150%. Not
scripted because it needs a logout/login to take effect and is easy to
verify wrong from the CLI.

### 5. Panel width → 40 and 6. Light theme (Scripted)

```bash
./scripts/mint/desktop-tweaks.sh
```

[`scripts/mint/desktop-tweaks.sh`](scripts/mint/desktop-tweaks.sh) sets:

- panel height to 40px (`org.cinnamon panels-height`)
- the Mint-Y light theme (GTK, Cinnamon, window manager, icons)

This is also the "light theme, also for Win11" step referenced in the
Windows section (step 11 above handles the Windows side).

### 7. Update & upgrade (Scripted)

Included at the top of `scripts/mint/bootstrap.sh` below, or standalone:

```bash
sudo apt update && sudo apt upgrade -y
```

### 8. Bootstrap tools + apps (Scripted)

```bash
./scripts/mint/bootstrap.sh
```

[`scripts/mint/bootstrap.sh`](scripts/mint/bootstrap.sh) does, in order:

1. `apt update && apt upgrade -y`
2. Nix (official multi-user installer, `--daemon`)
3. git
4. an `ed25519` SSH key → `ssh-agent` → pauses for you to add it to
   <https://github.com/settings/keys>
5. git identity (`user.name`, `user.email`, `init.defaultBranch main`)
6. [fresh IDE](https://github.com/sinelaw/fresh)
7. podman
8. Desktop apps — **apt only, Flatpak as fallback** (no third-party
   `.deb`/APT-repo installs):

   | App     | apt package            | Flatpak fallback              |
   |---------|-------------------------|--------------------------------|
   | Firefox | `firefox`               | `org.mozilla.firefox`         |
   | Chrome  | `google-chrome-stable`  | `com.google.Chrome`\*         |
   | Nuclear | `nuclear`               | `com.nuclearplayer.Nuclear`   |
   | Obsidian| `obsidian`              | `md.obsidian.Obsidian`        |
   | Discord | `discord`               | `com.discordapp.Discord`      |

   \* Google Chrome isn't in Mint's default apt repos, and we're
   intentionally not adding Google's own apt repo / installing a `.deb`
   here, so Chrome always falls through to its Flathub Flatpak
   (`com.google.Chrome`).

   Every other app on that list *is* expected to install via plain `apt` on
   a current Mint release; Flatpak only kicks in if that ever stops being
   true.

### 9. WhatsApp Web as a pinned app (Manual)

Cinnamon has no CLI for creating app shortcuts or panel pins, so this is
done entirely through the GUI:

1. Open Chrome (or your browser of choice) and go to
   <https://web.whatsapp.com>.
2. Menu (⋮) → **Cast, save, and share** → **Install page as app** (Chrome)
   — this creates a proper app entry with its own window and icon. In
   Firefox, use **Page → More tools → Add to Home Screen**, or just create a
   bookmark and skip straight to step 4 if you'd rather launch it as a
   pinned tab.
3. Launch the newly installed "WhatsApp" app once from the menu/desktop so
   it registers.
4. Right-click its icon in the **Menu** (or on the panel if it already
   appeared there) → **Add to panel** (or drag it onto the panel).

### 10. Enable the firewall (Scripted)

```bash
./scripts/mint/enable-firewall.sh
```

Just `sudo ufw enable` + `sudo ufw status verbose`.

---

## Script index

```
scripts/
├── windows/
│   ├── install-scoop.ps1           # Scoop package manager (Win11 step 11)
│   ├── post-install-apps.ps1       # winget apps + light theme (Win11 step 12)
│   └── wsl-move-to-partition.ps1   # move WSL distro onto its own partition (Win11 step 9)
├── wsl/
│   └── bootstrap.sh                 # nix, git, ssh+github, git config, fresh, podman (Win11 step 10)
└── mint/
    ├── bootstrap.sh                 # update, nix, git, ssh+github, git config, fresh, podman, apps (Mint step 8)
    ├── desktop-tweaks.sh            # panel width 40, light theme (Mint steps 5–6)
    └── enable-firewall.sh           # ufw enable (Mint step 10)
```
