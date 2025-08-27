
# Create aliases
alias cls="clear"
alias g="git"
alias n="nvim"
alias get_idf=". $HOME/esp_idf/esp-idf/export.fish"
function "uvpy"
    echo '{ "venvPath": ".", "venv": ".venv" }' > pyrightconfig.json
end

# TODO: Replace journal aliases after switching to OpenRC
# thefuck --alias | source 
alias mymicroscope="mpv av://v4l2:/dev/video2 --profile=low-latency --untimed"
alias mydualcam="mpv av://v4l2:/dev/video2 --profile=low-latency --untimed --demuxer-lavf-o=video_size=2560x720,input_format=mjpeg"

alias cat="bat --plain"

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
