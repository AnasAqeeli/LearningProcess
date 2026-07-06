#!/usr/bin/env bash
#
#  ansqli/dotfiles installer
#  ─────────────────────────
#  Symlinks every config in home/ into $HOME, backing up anything it
#  would overwrite. Safe to re-run any time; nothing is ever deleted.
#
#    ./install.sh              link configs (interactive)
#    ./install.sh --dry-run    show what would happen, touch nothing
#    ./install.sh --packages   also install packages (Arch/CachyOS)
#    ./install.sh --copy       copy files instead of symlinking
#    ./install.sh --uninstall  remove links & restore the latest backup
#    ./install.sh -y           assume "yes" to every prompt
#
#  Works standalone too — if this script is run outside a clone
#  (e.g. `bash <(curl -fsSL …/install.sh)`), it clones the repo first.
#
set -Eeuo pipefail

# Set this to your public repo before sharing (used only for bootstrapping).
REPO_URL="${DOTFILES_REPO:-https://github.com/ansqli/dotfiles.git}"
CLONE_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# ─── pretty output ────────────────────────────────────────────────────────
if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
    B=$'\e[1m' D=$'\e[2m' R=$'\e[0m'
    C_OK=$'\e[32m' C_WARN=$'\e[33m' C_ERR=$'\e[31m' C_ACC=$'\e[36m' C_MAG=$'\e[35m'
else
    B='' D='' R='' C_OK='' C_WARN='' C_ERR='' C_ACC='' C_MAG=''
fi
say()  { printf '%s\n' "$*"; }
step() { printf '\n%s──►%s %s%s%s\n' "$C_ACC" "$R" "$B" "$*" "$R"; }
ok()   { printf '  %s✔%s %s\n' "$C_OK" "$R" "$*"; }
info() { printf '  %s●%s %s\n' "$D" "$R" "$*"; }
warn() { printf '  %s▲%s %s\n' "$C_WARN" "$R" "$*"; }
err()  { printf '  %s✖ %s%s\n' "$C_ERR" "$*" "$R" >&2; }
trap 'err "install.sh failed at line $LINENO — nothing lost: backups live in ${BACKUP_ROOT:-$HOME/.dotfiles-backup}"' ERR

banner() {
    printf '%s' "$C_MAG"
    cat <<'EOF'

   ╭─────────────────────────────────────────────╮
   │      a n s q l i   ·   d o t f i l e s      │
   │      niri ✕ noctalia ✕ pywal ✕ fish         │
   ╰─────────────────────────────────────────────╯
EOF
    printf '%s' "$R"
}

# ─── options ──────────────────────────────────────────────────────────────
DRY=0 COPY=0 PACKAGES=0 UNINSTALL=0 YES=0
for arg in "$@"; do
    case $arg in
        -n|--dry-run)   DRY=1 ;;
        --copy)         COPY=1 ;;
        -p|--packages)  PACKAGES=1 ;;
        --uninstall)    UNINSTALL=1 ;;
        -y|--yes)       YES=1 ;;
        -h|--help)      awk 'NR>1 && !/^#/{exit} NR>1{sub(/^# ? ?/,""); print}' "$0"; exit 0 ;;
        *) err "unknown option: $arg (try --help)"; exit 1 ;;
    esac
done
[[ -t 0 ]] || YES=1   # piped in (curl | bash) → no way to prompt

confirm() { # confirm "question" → 0/1, honors -y
    (( YES )) && return 0
    read -rp "  $1 [Y/n] " reply
    [[ -z $reply || $reply =~ ^[Yy] ]]
}

# ─── locate (or bootstrap) the repo ───────────────────────────────────────
SCRIPT_SRC="${BASH_SOURCE[0]:-}"
if [[ -n $SCRIPT_SRC && -f $SCRIPT_SRC && -d "$(dirname "$SCRIPT_SRC")/home" ]]; then
    REPO_DIR=$(cd "$(dirname "$SCRIPT_SRC")" && pwd -P)
else
    banner
    step "Bootstrapping — cloning the repo"
    command -v git >/dev/null || { err "git is required to bootstrap"; exit 1; }
    if [[ -d $CLONE_DIR/home ]]; then
        info "existing clone found at $CLONE_DIR — pulling latest"
        git -C "$CLONE_DIR" pull --ff-only || warn "pull failed, using clone as-is"
    else
        git clone --depth=1 "$REPO_URL" "$CLONE_DIR"
    fi
    exec "$CLONE_DIR/install.sh" "$@"
fi

BACKUP_ROOT="$HOME/.dotfiles-backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"

# Machine state worth carrying across the link switch (repo .gitignore's these)
KEEP_STATE=(
    ".config/fish/fish_variables"
    ".config/fish/completions"
    ".config/micro/syntax"
    ".config/micro/buffers"
    ".config/gtk-3.0/bookmarks"
)

# ─── build the target list ────────────────────────────────────────────────
# Every top-level entry in home/ is linked directly into $HOME, except
# .config, whose *children* are linked (so unrelated app configs coexist).
TARGETS=() # relative paths, e.g. ".gitconfig" ".config/niri"
while IFS= read -r entry; do
    if [[ $entry == .config ]]; then
        while IFS= read -r sub; do TARGETS+=(".config/$sub"); done \
            < <(find "$REPO_DIR/home/.config" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)
    else
        TARGETS+=("$entry")
    fi
done < <(find "$REPO_DIR/home" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)

# ─── engine ───────────────────────────────────────────────────────────────
N_LINK=0 N_SKIP=0 N_BACK=0 DID_BACKUP=0

backup() { # backup <abs path> <rel path>
    local abs=$1 rel=$2
    (( DRY )) && { warn "$rel exists → would back up"; return; }
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$abs" "$BACKUP_DIR/$rel"
    DID_BACKUP=1; (( ++N_BACK ))
}

deploy() { # deploy <rel path>
    local rel=$1 src="$REPO_DIR/home/$1" dst="$HOME/$1"

    if [[ -L $dst && $(readlink "$dst") == "$src" && $COPY == 0 ]]; then
        info "$rel ${D}already linked${R}"; (( ++N_SKIP )); return
    fi
    if [[ -e $dst || -L $dst ]]; then
        backup "$dst" "$rel"
    fi
    if (( DRY )); then
        say "  ${D}→ would $( ((COPY)) && echo copy || echo link ) $rel${R}"; return
    fi
    mkdir -p "$(dirname "$dst")"
    if (( COPY )); then
        cp -a "$src" "$dst"; ok "$rel ${D}copied${R}"
    else
        ln -sT "$src" "$dst"; ok "$rel ${D}→ $(realpath -s --relative-to="$HOME" "$src")${R}"
    fi
    (( ++N_LINK ))
}

restore_state() { # carry fish_variables & friends into the freshly linked dirs
    (( DID_BACKUP && !DRY )) || return 0
    local rel
    for rel in "${KEEP_STATE[@]}"; do
        if [[ -e "$BACKUP_DIR/$rel" && ! -e "$HOME/$rel" ]]; then
            cp -a "$BACKUP_DIR/$rel" "$HOME/$rel"
            info "kept machine state: $rel"
        fi
    done
}

# ─── uninstall ────────────────────────────────────────────────────────────
if (( UNINSTALL )); then
    banner
    step "Removing dotfile links"
    for rel in "${TARGETS[@]}"; do
        dst="$HOME/$rel"
        if [[ -L $dst && $(readlink -f "$dst" 2>/dev/null) == "$REPO_DIR"/* ]]; then
            if (( DRY )); then say "  ${D}→ would unlink $rel${R}"; else rm "$dst"; ok "unlinked $rel"; fi
        fi
    done
    latest=$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -1 || true)
    if [[ -n ${latest:-} ]]; then
        step "Restoring backup $(basename "$latest")"
        if (( DRY )); then
            say "  ${D}→ would restore $(find "$latest" -mindepth 1 -maxdepth 2 | wc -l) items${R}"
        else
            (cd "$latest" && find . -mindepth 1 -maxdepth 3 \( -type f -o -type d -o -type l \) -print0) |
            while IFS= read -r -d '' item; do
                rel=${item#./}
                [[ -e "$HOME/$rel" || -L "$HOME/$rel" ]] && continue
                mkdir -p "$HOME/$(dirname "$rel")"
                cp -a "$latest/$rel" "$HOME/$rel" 2>/dev/null || true
            done
            ok "restored what was missing (backup kept at $latest)"
        fi
    else
        info "no backups found to restore"
    fi
    say ""; ok "uninstalled — your previous configs are back"
    exit 0
fi

# ─── install ──────────────────────────────────────────────────────────────
banner
say "  ${D}repo:${R}   $REPO_DIR"
say "  ${D}target:${R} $HOME"
(( DRY ))  && say "  ${C_WARN}dry-run — nothing will be changed${R}"
(( COPY )) && say "  ${C_WARN}copy mode — files are copied, not symlinked${R}"

# capture git identity *before* we replace ~/.gitconfig
GIT_NAME=$(git config --global --get user.name 2>/dev/null || true)
GIT_MAIL=$(git config --global --get user.email 2>/dev/null || true)

step "Linking ${#TARGETS[@]} configs into \$HOME"
if ! confirm "Existing files get a timestamped backup in ~/.dotfiles-backup. Continue?"; then
    say "  aborted — nothing was changed."; exit 0
fi
for rel in "${TARGETS[@]}"; do deploy "$rel"; done
restore_state

# ─── personalization ──────────────────────────────────────────────────────
step "Personalizing"

# 1. git identity → ~/.gitconfig.local (kept out of the repo)
if [[ ! -e $HOME/.gitconfig.local ]]; then
    if [[ -z $GIT_NAME && $YES == 0 ]]; then
        read -rp "  git user.name  (Enter to skip): " GIT_NAME || true
        read -rp "  git user.email (Enter to skip): " GIT_MAIL || true
    fi
    if (( ! DRY )); then
        {
            echo "# Your private git identity — not tracked by the dotfiles repo."
            echo "[user]"
            [[ -n $GIT_NAME ]] && echo "	name = $GIT_NAME"
            [[ -n $GIT_MAIL ]] && echo "	email = $GIT_MAIL"
        } > "$HOME/.gitconfig.local"
        ok "wrote ~/.gitconfig.local${GIT_NAME:+ ($GIT_NAME)}"
    fi
else
    info "~/.gitconfig.local already present"
fi

# 2. absolute paths inside noctalia's settings follow whoever installs this
if [[ $HOME != /home/ansqli && $DRY == 0 ]]; then
    sed -i "s|/home/ansqli|$HOME|g" "$REPO_DIR/home/.config/noctalia/settings.json"
    ok "pointed noctalia paths at $HOME"
fi
(( DRY )) || mkdir -p "$HOME/Pictures/Wallpapers"

# ─── packages (Arch / CachyOS) ────────────────────────────────────────────
if (( PACKAGES )); then
    step "Installing packages"
    if ! command -v pacman >/dev/null; then
        warn "not an Arch-based system — install these yourself:"
        sed 's/#.*//' "$REPO_DIR/packages/arch.txt" | awk 'NF' | sed 's/^/      /'
    else
        mapfile -t wanted < <(sed 's/#.*//' "$REPO_DIR/packages/arch.txt" | awk 'NF{print $1}')
        mapfile -t missing < <(comm -23 <(printf '%s\n' "${wanted[@]}" | sort -u) <(pacman -Qq | sort))
        if (( ${#missing[@]} == 0 )); then
            ok "all ${#wanted[@]} packages already installed"
        else
            mapfile -t in_repo < <(comm -12 <(printf '%s\n' "${missing[@]}") <(pacman -Slq | sort -u))
            mapfile -t in_aur  < <(comm -23 <(printf '%s\n' "${missing[@]}") <(pacman -Slq | sort -u))
            say "  missing: ${B}${missing[*]}${R}"
            if (( DRY )); then
                info "dry-run: would install ${#in_repo[@]} from repos, ${#in_aur[@]} from AUR"
            elif confirm "Install ${#missing[@]} packages now?"; then
                (( ${#in_repo[@]} )) && sudo pacman -S --needed --noconfirm "${in_repo[@]}"
                if (( ${#in_aur[@]} )); then
                    helper=$(command -v paru || command -v yay || true)
                    if [[ -n $helper ]]; then
                        "$helper" -S --needed --noconfirm "${in_aur[@]}" || warn "AUR install had errors"
                    else
                        warn "no AUR helper (paru/yay) — install manually: ${in_aur[*]}"
                    fi
                fi
                ok "package installation finished"
            fi
        fi
    fi
fi

# ─── first-run niceties ───────────────────────────────────────────────────
step "Finishing touches"
if command -v wal >/dev/null; then
    if [[ ! -s $HOME/.cache/wal/colors.json ]]; then
        if (( DRY )); then
            info "dry-run: would seed pywal with the gruvbox palette"
        elif wal --theme gruvbox >/dev/null 2>&1; then
            cp -f "$HOME/.cache/wal/colors-noctalia.json" "$HOME/.config/noctalia/colors.json" 2>/dev/null || true
            ok "seeded pywal with gruvbox (run 'wal -i <wallpaper>' to make it yours)"
        else
            warn "couldn't seed pywal — run 'wal -i <image>' once before starting alacritty"
        fi
    else
        info "pywal cache already present"
    fi
else
    warn "pywal not installed — alacritty/fuzzel import ~/.cache/wal/* (use --packages)"
fi
[[ ${SHELL:-} == *fish ]] || info "make fish your login shell:  chsh -s $(command -v fish 2>/dev/null || echo /usr/bin/fish)"

# ─── summary ──────────────────────────────────────────────────────────────
say ""
say "   ${C_MAG}─────────────────────────────────────────────────${R}"
say "    ${B}done ✦${R}  linked $N_LINK · unchanged $N_SKIP · backed up $N_BACK"
say "   ${C_MAG}─────────────────────────────────────────────────${R}"
(( DID_BACKUP )) && say "   ${D}backups: $BACKUP_DIR${R}"
say ""
say "   next steps"
say "   ${D}·${R} log out → pick the ${B}niri${R} session"
say "   ${D}·${R} ${B}Mod+Shift+Esc${R} shows every keybind"
say "   ${D}·${R} drop images in ~/Pictures/Wallpapers, set one via noctalia"
say "     or run ${B}wal -i <image>${R} — terminal, launcher, bar & borders all recolor"
say "   ${D}·${R} monitors are machine-specific: tweak ${B}~/.config/niri/cfg/display.kdl${R}"
say "   ${D}·${R} ${B}dots${R} (in fish) jumps to this repo · ${B}dots status${R} shows config drift"
say ""
