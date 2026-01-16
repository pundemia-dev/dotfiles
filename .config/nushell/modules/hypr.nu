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

