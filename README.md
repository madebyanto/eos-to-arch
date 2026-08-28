# endeavouros-to-arch

A simple shell script to rebrand an [EndeavourOS](https://endeavouros.com/) installation as pure [Arch Linux](https://archlinux.org/) — replacing `os-release` and installing the official Arch Linux icons into the system theme.

> **This script does not reinstall packages or alter your system beyond branding files.** It is a cosmetic conversion only.

---

## Requirements

- EndeavourOS (the script refuses to run on anything else)
- Root privileges (`sudo`)
- `gtk-update-icon-cache` (optional — from `gtk-update-icon-cache` or `gtk3`; skipped gracefully if absent)

---

## Project structure

```
install.sh
os/
└── os-release          # Arch Linux os-release to install
assets/
├── scalable/
│   └── arch.svg
├── 48x48/
│   └── arch.png
└── 256x256/
    └── arch.png
```

---

## What it does

| Step | Action |
|------|--------|
| 1 | Verifies the system is running EndeavourOS |
| 2 | Backs up `/etc/os-release` → `/etc/os-release.bak` |
| 3 | Replaces `/etc/os-release` with `os/os-release` |
| 4 | Installs Arch Linux icons into `/usr/share/icons/hicolor/` |
| 5 | Runs `gtk-update-icon-cache` if available |

---

## Usage

```bash
git clone https://github.com/youruser/endeavouros-to-arch.git
cd endeavouros-to-arch
chmod +x install.sh
sudo ./install.sh
```

A logout or reboot may be needed for all changes to take effect.

---

## Reverting

The original `os-release` is preserved at `/etc/os-release.bak`. To revert:

```bash
sudo cp /etc/os-release.bak /etc/os-release
```

Icons can be removed manually from `/usr/share/icons/hicolor/`.

---

## License

MIT License — see [LICENSE](LICENSE).

> The Arch Linux name and logo are registered trademarks of Arch Linux.  
> See [https://archlinux.org/art/](https://archlinux.org/art/) for usage terms.  
> This project is not affiliated with or endorsed by the Arch Linux project.