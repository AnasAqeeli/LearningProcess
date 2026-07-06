function display-2monitors
    cp ~/.config/niri/cfg/display-2monitors.kdl ~/.config/niri/cfg/display.kdl
    niri msg action load-config-file
end
