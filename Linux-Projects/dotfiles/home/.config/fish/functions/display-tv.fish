function display-tv
    cp ~/.config/niri/cfg/display-tv.kdl ~/.config/niri/cfg/display.kdl
    niri msg action load-config-file
end
