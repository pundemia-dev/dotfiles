def _hyrpctl_subcommands [] {
    [
        "activewindow", "activeworkspace", "animations", "binds", "clients", "configerrors", "cursorpos",
        "decorations", "devices", "dismissnotify", "dispatch", "getoption", "globalshortcuts", "hyprpaper",
        "hyprsunset", "instances", "keyword","kill", "layers", "layouts", "monitors", "notify", "output",
        "plugin", "reload", "rollinglog", "setcursor", "seterror", "setprop", "splash", "switchxkblayout",
        "systeminfo", "version", "workspacerules", "workspaces"
    ]
}

def --wrapped hypr [
    subcommand: string@_hyrpctl_subcommands
    ...rest: string
]: nothing -> any {
    ^hyprctl -j $subcommand ...$rest | from json | transpose index | explore -i --head false
}

def pfetch [] {
    clear
    print "\n" # Дополнительный отступ, чтобы точно не наезжало
    fastfetch --logo `~/Downloads/Untitled (Copy)@3x.png` --logo-width 25 --logo-padding-top 1
}
def pfetch-float [] {
    hyprctl dispatch setfloating
    hyprctl dispatch resizeactive exact 687 416
    hyprctl dispatch centerwindow
    clear
    print "\n" # Дополнительный отступ, чтобы точно не наезжало
    fastfetch --logo `~/Downloads/Untitled (Copy)@3x.png` --logo-width 25 --logo-padding-top 1
}
def clock-float [] {
    hyprctl dispatch setfloating
    hyprctl dispatch resizeactive exact 334 183
    hyprctl dispatch centerwindow
    tty-clock
}
