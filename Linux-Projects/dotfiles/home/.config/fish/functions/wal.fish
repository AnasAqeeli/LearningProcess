function wal -d "pywal wrapper: also re-theme noctalia-shell and niri"
    # Run the real pywal first; bail out if it fails (e.g. bad image path).
    command wal $argv; or return

    set -l cache $HOME/.cache/wal

    # Hand the generated palette to noctalia-shell
    # (~/.config/wal/postrun does this too when pywal supports post-run hooks;
    #  doing it here as well keeps the pipeline working on vanilla pywal).
    if test -r $cache/colors-noctalia.json
        cp $cache/colors-noctalia.json $HOME/.config/noctalia/colors.json
    end

    # Recolor niri's focus ring to match. niri watches its config files,
    # so the sed below live-reloads the borders instantly.
    if test -r $cache/colors.json
        set -l c (python3 -c "import json; d = json.load(open('$cache/colors.json'))['colors']; print(d['color5']); print(d['color1'])")
        if test (count $c) -eq 2
            sed -i "s/active-color \".*\"/active-color \"$c[1]\"/" $HOME/.config/niri/cfg/layout.kdl
            sed -i "s/inactive-color \".*\"/inactive-color \"$c[2]\"/" $HOME/.config/niri/cfg/layout.kdl
        end
    end
end
