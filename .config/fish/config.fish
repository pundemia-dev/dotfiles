alias pfetch='clear; printf "\n"; fastfetch --logo ~/Downloads/Untitled\ \(Copy\)@3x.png --logo-width 25 --logo-padding-top 1'
alias pfetch-float='hyprctl dispatch setfloating; hyprctl dispatch resizeactive exact 687 416; hyprctl dispatch centerwindow; clear; printf "\n"; fastfetch --logo ~/Downloads/Untitled\ \(Copy\)@3x.png --logo-width 25 --logo-padding-top 1'
alias clock-float='hyprctl dispatch setfloating; hyprctl dispatch resizeactive exact 334 183; hyprctl dispatch centerwindow; tty-clock'

# function cpv
#     cp $argv &
#     set pid (jobs --last --pid)
#     pv -d $pid 2>&1 | grep (basename $argv[-1])
#     wait $pid
# end

# function cpv
#     cp $argv &
#     set pid (jobs --last --pid)
#     pv -d $pid -p
#     wait $pid
# end
function cpv
    cp $argv &
    set pid (jobs --last --pid)
    pv -d $pid -i 0.05 -p -u block
    wait $pid
end

function h1
    figlet -f starwars $argv | tee /dev/tty | fish_clipboard_copy
end

function h2
    figlet -f standard $argv | tee /dev/tty | fish_clipboard_copy
end

function h3
    figlet -f small $argv | tee /dev/tty | fish_clipboard_copy
end

function h4
    figlet -f straight $argv | tee /dev/tty | fish_clipboard_copy
end

function h5
    figlet -f short $argv | tee /dev/tty | fish_clipboard_copy
end
alias icat="kitten icat"
alias cls="clear"
alias g="git"
alias n="nvim"
alias get_idf=". $HOME/esp_idf/esp-idf/export.fish"
alias cr="cargo run"
alias walltool="~/.config/quickshell/pShell/utils/scripts/walltool/target/debug/walltool"
function uvpy
    echo '{ "venvPath": ".", "venv": ".venv" }' >pyrightconfig.json
end

function catall
    find . -type f -print0 | while read -z file
        printf '%s\n' "$file"
        cat -- "$file"
    end | wl-copy
end

# function "catcur"
#     find . -maxdepth 1 -type f -print0 | while read -z file
#         printf '%s\n' "$file"
#         cat -- "$file"
#     end | wl-copy
# end

function catcur
    set -l exclude_patterns ()
    set -l skip_next false

    # Парсим аргументы
    for arg in $argv
        if test "$skip_next" = true
            set exclude_patterns $exclude_patterns "$arg"
            set skip_next false
        else if test "$arg" = --exclude
            set skip_next true
        end
    end

    # Строим условие для find
    set -l find_cmd "find . -maxdepth 1 -type f"
    for pattern in $exclude_patterns
        set find_cmd "$find_cmd ! -name '$pattern'"
    end

    # Выполняем команду
    eval $find_cmd -print0 | while read -z file
        printf '%s\n' "$file"
        cat -- "$file"
    end | wl-copy
end

# function "catcur"
#     eza --only-files --no-symlinks | while read -z file
#         printf '%s\n' "$file"
#         cat -- "$file"
#     end | wl-copy
# end

# TODO: Replace journal aliases after switching to OpenRC
# thefuck --alias | source 
function zed
    # 1. Получаем адрес текущего окна терминала через hyprctl
    set term_address (hyprctl activewindow -j | jq -r '.address')

    # 2. Скрываем терминал (отправляем в специальный воркспейс "minimized")
    hyprctl dispatch movetoworkspacesilent special:minimized,address:$term_address

    # 3. Запускаем Zed с флагом --wait. 
    # Он будет блокировать консоль, пока вы не закроете вкладку или окно Zed.
    # Передаем все аргументы, которые ввели (например, путь к файлу)
    zeditor --wait $argv

    # 4. Когда Zed закрылся, возвращаем терминал на текущий активный воркспейс
    hyprctl dispatch movetoworkspace (hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .activeWorkspace.id'),address:$term_address

    # 5. Возвращаем фокус на терминал
    hyprctl dispatch focuswindow address:$term_address
end
function sudo --description "Replacement for Bash 'sudo !!' command to run last command using sudo."
    if test "$argv" = !!
        echo sudo $history[1]
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end
# VPN
function vpn
    if test (count $argv) -eq 0
        echo "Usage: vpn <command> [args]"
        echo "Commands: start, stop, restart, kill, autostart on|off, status, logs [new], update <json string>, help"
        return 1
    end

    set cmd $argv[1]

    switch $cmd
        case start
            sudo systemctl start sing-box

        case stop
            sudo systemctl stop sing-box

        case restart
            sudo systemctl restart sing-box

        case kill
            sudo systemctl kill sing-box

        case autostart
            if test (count $argv) -lt 2
                echo "Usage: vpn autostart on|off"
                return 1
            end
            switch $argv[2]
                case on
                    sudo systemctl enable sing-box
                case off
                    sudo systemctl disable sing-box
                case '*'
                    echo "Usage: vpn autostart on|off"
            end

        case logs
            if test (count $argv) -ge 2 -a $argv[2] = new
                sudo journalctl -u sing-box --output cat -f
            else
                sudo journalctl -u sing-box --output cat -e
            end

        case update
            if test (count $argv) -lt 2
                echo "Usage: vpn update '<json_string>'"
                return 1
            end

            if not type -q jq
                echo (set_color red)"[ WARN ]"(set_color normal) - jq not found, install it: sudo pacman -S jq
                return 1
            end

            echo "$argv[2..-1]" | jq . >/tmp/vpn_update_tmp.json

            if test $status -ne 0
                echo (set_color red)"[ WARN ]"(set_color normal) - JSON is not valid
                rm -f /tmp/vpn_update_tmp.json
                return 1
            end

            echo (set_color green)"[ INFO ]"(set_color normal) - Updating /etc/sing-box/config.json
            sudo mv /tmp/vpn_update_tmp.json /etc/sing-box/config.json

            if test $status -eq 0
                echo (set_color green)"[ INFO ]"(set_color normal) - Config updated: /etc/sing-box/config.json
                cat /etc/sing-box/config.json
            else
                echo (set_color red)"[ WARN ]"(set_color normal) - Error writing file
            end

        case status
            set state (systemctl is-active sing-box)

            if test $state = active
                echo (set_color green)"[ INFO ]"(set_color normal) - sing-box is running
            else if test $state = inactive
                echo (set_color red)"[ WARN ]"(set_color normal) - sing-box is stopped
            else
                echo (set_color red)"[ WARN ]"(set_color normal) - sing-box state: $state
            end

        case help -h --help
            echo "vpn <command> [args]"
            echo "Commands:"
            echo "  start                Start sing-box service"
            echo "  stop                 Stop sing-box service"
            echo "  restart              Restart sing-box service"
            echo "  kill                 Kill sing-box service"
            echo "  autostart on|off     Enable or disable autostart"
            echo "  status               Show vpn status"
            echo "  logs [new]           Show logs, 'new' for live"
            echo "  update <json_string> Update /etc/sing-box/config.json with JSON"
            echo "  help, -h, --help     Show this help message"

        case '*'
            echo "Unknown command: $cmd"
            echo "Use 'vpn help' for usage"
    end
end

alias mymicroscope="mpv av://v4l2:/dev/video2 --profile=low-latency --untimed"
alias mydualcam="mpv av://v4l2:/dev/video2 --profile=low-latency --untimed --demuxer-lavf-o=video_size=2560x720,input_format=mjpeg"

# alias ocat="cat"
# alias cat="bat --plain --color=always --theme='Catppuccin Macchiato'"

alias ls="eza --color=always --icons=always -1"
alias tree="eza -T"

alias pbcopy="wl-copy"

alias progress="progress -mp $last_pid"

function show_updates
    set --local pac_updates (checkupdates)
    set --local yay_updates (yay -Qua)

    printf "󰮯 Pacman packages (%d):\n" (count $pac_updates)
    printf "%s\n" $pac_updates
    printf "\n Yay packages (%d):\n" (count $yay_updates)
    printf "%s\n" $yay_updates
end

# show_updates

# Display critical errors
alias syslog_emerg="sudo dmesg --level=emerg,alert,crit"

# Output common errors
alias syslog="sudo dmesg --level=err,warn"

# Print logs from x server
alias xlog='grep "(EE)\|(WW)\|error\|failed" ~/.local/share/xorg/Xorg.0.log'

# Remove archived journal files until the disk space they use falls below 100M
alias vacuum="journalctl --vacuum-size=100M"

# Make all journal files contain no data older than 2 weeks
alias vacuum_time="journalctl --vacuum-time=2weeks"

set -U fish_greeting
set fish_color_command green
set -gx BROWSER /usr/bin/zen-browser
set -gx SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/pundemia/.lmstudio/bin

zoxide init fish --cmd cd | source

# uv
fish_add_path "/home/pundemia/.local/bin"

# ~/.config/fish/config.fish

starship init fish | source
