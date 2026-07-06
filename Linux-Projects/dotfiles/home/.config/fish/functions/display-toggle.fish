function display-toggle
    if diff ~/.config/niri/cfg/display.kdl ~/.config/niri/cfg/display-2monitors.kdl > /dev/null 2>&1
        cp ~/.config/niri/cfg/display-tv.kdl ~/.config/niri/cfg/display.kdl
    else
        cp ~/.config/niri/cfg/display-2monitors.kdl ~/.config/niri/cfg/display.kdl
    end
    niri msg action load-config-file
end
