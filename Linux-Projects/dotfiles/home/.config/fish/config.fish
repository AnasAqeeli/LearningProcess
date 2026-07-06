# ─────────────────────────────────────────────
#  fish config — ansqli's dotfiles
# ─────────────────────────────────────────────

# CachyOS ships a great default config (aliases, fzf keybinds, fastfetch
# greeting). Source it when present, fall back to sane basics elsewhere
# so this config works on any distro.
if test -r /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
else
    set -g fish_greeting # no greeting on non-CachyOS systems
    alias ls 'ls --color=auto'
    alias ll 'ls -lah'
    alias grep 'grep --color=auto'
    alias .. 'cd ..'
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# ─── PATH ───
# opencode
if test -d $HOME/.opencode/bin
    fish_add_path $HOME/.opencode/bin
end
