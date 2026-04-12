alias n = nvim
# alias cat = bat --plain --color=always --theme='Catppuccin Macchiato'
alias icat = kitten icat
alias cr = cargo run
alias walltool = ~/.config/quickshell/pShell/scripts/walltool/target/release/walltool
# alias tree = eza -T --icons=always
alias mymicroscope = mpv av://v4l2:/dev/video2 --profile=low-latency --untimed
alias mydualcam = mpv av://v4l2:/dev/video2 --profile=low-latency --untimed --demuxer-lavf-o=video_size=2560x720,input_format=mjpeg



# Display a file tree with icons (using eza).
#
# Examples:
#   tree -L3   -> Limit the depth of the tree to 3 levels
#   tree -a     -> Show hidden (dot) files
def --wrapped tree [...args] {
    ^eza -T --icons=always ...$args
}

def catcur [] {
    ls
    | where type == file
    | each { |it|
        [
            $"===== ($it.name) ====="
            ( ^cat $it.name )
            ""
        ] | str join "\n"
    }
    | str join "\n"
    | ^wl-copy
}

def catall [] {
    ls **/*
    | where type == file
    | each { |it|
        [
            $"===== ($it.name) ====="
            ( ^cat $it.name )
            ""
        ] | str join "\n"
    }
    | str join "\n"
    | ^wl-copy
}
