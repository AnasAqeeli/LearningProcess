# ansqli · dotfiles

> **niri ✕ noctalia ✕ pywal ✕ fish** — a scrollable-tiling Wayland desktop where
> one command re-themes *everything*: terminal, launcher, bar, lockscreen and
> window borders, all from the colors of your wallpaper.

Built on [CachyOS](https://cachyos.org), works on any Arch-based distro
(and the configs link fine anywhere Linux).

<!-- screenshot: drop one at assets/screenshot.png and uncomment -->
<!-- ![screenshot](assets/screenshot.png) -->

## Install

These dotfiles live inside the
[LearningProcess](https://github.com/AnasAqeeli/LearningProcess) monorepo,
under `Linux-Projects/dotfiles`:

```bash
git clone https://github.com/AnasAqeeli/LearningProcess.git
cd LearningProcess/Linux-Projects/dotfiles
./install.sh
```

Or without cloning anything first (the script clones for you):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnasAqeeli/LearningProcess/main/Linux-Projects/dotfiles/install.sh)
```

The installer links the configs **and offers to install every missing
program** from the [package list](packages/arch.txt) — the keybinds depend
on them (alacritty, fuzzel, brave, thunar, nirimod, …). Anything already on
the system is detected and left alone, so on CachyOS's niri edition it
won't touch the preinstalled niri/noctalia.

**It never deletes anything.** Every file it would touch is moved to
`~/.dotfiles-backup/<timestamp>/` first, and `./install.sh --uninstall`
puts it all back. Re-running is always safe — already-linked configs are
skipped.

| flag | effect |
|---|---|
| `--dry-run` | print the plan, change nothing |
| `--packages` | install missing packages without asking (pacman + paru/yay) |
| `--no-packages` | link configs only, skip package installation |
| `--copy` | copy files instead of symlinking |
| `--uninstall` | remove the links, restore your backed-up configs |
| `-y` | no questions asked |

## What's inside

| | |
|---|---|
| **compositor** | [niri](https://github.com/YaLTeR/niri) — scrollable tiling, config split into `cfg/*.kdl` modules |
| **shell** | [noctalia](https://docs.noctalia.dev) — bar, launcher, lockscreen, wallpaper, OSD (+ polkit-agent plugin) |
| **launcher** | fuzzel |
| **terminal** | alacritty |
| **shell (cli)** | fish (+ CachyOS defaults when available, graceful fallback elsewhere) |
| **editors** | neovim (LazyVim + IDE-style Ctrl keymaps + pywal theme) · micro (catppuccin) |
| **monitor** | btop |
| **theming** | pywal → everything (see below) |

## The theming pipeline

Set a wallpaper and the whole desktop follows:

```
 wal -i wallpaper.png            (or pick one in noctalia's wallpaper selector)
   │
   ├─ ~/.cache/wal/alacritty.toml      → terminal colors   (live reload)
   ├─ ~/.cache/wal/colors-fuzzel.ini   → launcher colors
   ├─ ~/.cache/wal/colors-noctalia.json→ bar/lock/OSD colors
   └─ fish `wal` wrapper seds niri's   → focus-ring borders (live reload)
      layout.kdl active/inactive color
```

Templates live in [`home/.config/wal/templates/`](home/.config/wal/templates).
Noctalia's startup hook runs `wal -R`, so the palette survives reboots.

## Keybinds you'll actually use

*`Mod+Shift+Esc` shows the full, always-current list.*

| keys | action |
|---|---|
| `Ctrl+Alt+T` | terminal |
| `Mod+S` | app launcher |
| `Mod+B` / `Mod+E` | browser / files |
| `Mod+H/J/K/L` or arrows (or `Mod+A/D`) | focus column/window |
| `Mod+Ctrl+…` | move column/window |
| `Mod+1–9` · `Mod+Tab` | workspaces · previous workspace |
| `Mod+O` | overview |
| `Mod+F` / `Mod+M` / `Mod+C` | expand / 50 % / center column |
| `Mod+T` / `Mod+W` | float / tabbed column |
| `Mod+Alt+L` / `Mod+Shift+Q` | lock / session menu |
| `Mod+F8` | toggle desk ↔ TV display profile |
| `Alt+-` / `Alt+=` | mute mic / deafen |

## Monitor profiles

`display.kdl` is whatever profile is active; the fish functions
`display-2monitors`, `display-tv` and `display-toggle` (bound to `Mod+F8`)
copy a profile over it and hot-reload niri. Output names are machine-specific —
edit `home/.config/niri/cfg/display*.kdl` for your hardware (or use
`nwg-displays`), and the extra `output` blocks for monitors you don't have are
simply ignored.

## Living with it

Configs are **symlinks into this repo**, so the repo always reflects reality:

```fish
dots            # cd into the repo, wherever it lives
dots status     # what changed since the last commit?
dots add -p     # commit the tweaks you want to keep
```

Machine-local state (fish universal variables, micro buffers, GTK bookmarks…)
is `.gitignore`d and preserved across installs, and your git identity lives in
`~/.gitconfig.local` — sharing this repo never leaks your name/email.

## Layout

```
dotfiles/
├── install.sh            # backup-first linker · bootstrap · packages
├── packages/arch.txt     # one package per line, comments allowed
└── home/                 # mirrors $HOME 1:1
    ├── .gitconfig        #   → ~/.gitconfig  (identity via ~/.gitconfig.local)
    └── .config/
        ├── niri/         #   config.kdl + cfg/{keybinds,layout,input,…}.kdl
        ├── noctalia/     #   shell settings + pywal template + polkit plugin
        ├── fish/         #   config + wal/display/dots functions
        ├── alacritty/ fuzzel/ btop/ micro/ nvim/ wal/ gtk-3.0/
        └── …             # drop a new dir here → next install links it
```

## License

[MIT](LICENSE) — take whatever you like.
