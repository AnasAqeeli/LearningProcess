function dots -d "cd into the dotfiles repo, or run a git command in it: dots status"
    # config.fish is a symlink into the repo — follow it to find the repo root.
    set -l repo (path resolve ~/.config/fish/config.fish | path dirname | path dirname | path dirname | path dirname)
    if not test -d $repo/.git
        echo "dots: couldn't locate the dotfiles repo (is fish config symlinked?)" >&2
        return 1
    end
    if test (count $argv) -gt 0
        git -C $repo $argv
    else
        cd $repo
    end
end
