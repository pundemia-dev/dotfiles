alias n = nvim
alias cat = bat --plain
alias tree = eza -T --icons=always
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

# Display a file tree with icons (using eza).
#
# Examples:
#   tree -L3   -> Limit the depth of the tree to 3 levels
#   tree -a     -> Show hidden (dot) files
def --wrapped tree [...args] {
    ^eza -T --icons=always ...$args
}
def update-kitty-theme [] {
    let src_path = ($env.HOME | path join ".config/hypr/scheme/current.conf")
    let dest_path = ($env.HOME | path join ".config/kitty/themes/current-theme.conf")

    # 1. Читаем файл.
    let theme_data = (open $src_path | lines | parse "{key} = {val}")

    # Замыкание для поиска цвета
    let get_color = {|name| 
        let search_key = ("$" + $name)
        let res = ($theme_data | where key == $search_key)
        if ($res | is-empty) { 
            "FF0000" 
        } else { 
            $res.val.0 
        }
    }

    # 2. Собираем конфиг.
    # ВАЖНО: Убраны скобки вокруг "0-15", чтобы Nushell не пытался это выполнить.
    let kitty_conf = $"
# Generated from Hyprland scheme at (date now)

# --- Core Colors ---
background            #(do $get_color 'background')
foreground            #(do $get_color 'text')
selection_background  #(do $get_color 'secondaryContainer')
selection_foreground  #(do $get_color 'onSecondaryContainer')
url_color             #(do $get_color 'primary')
cursor                #(do $get_color 'primary')
cursor_text_color     #(do $get_color 'onPrimary')

# --- Borders ---
active_border_color   #(do $get_color 'primary')
inactive_border_color #(do $get_color 'outline')

# --- Term Colors 0-15 ---
color0  #(do $get_color 'term0')
color1  #(do $get_color 'term1')
color2  #(do $get_color 'term2')
color3  #(do $get_color 'term3')
color4  #(do $get_color 'term4')
color5  #(do $get_color 'term5')
color6  #(do $get_color 'term6')
color7  #(do $get_color 'term7')
color8  #(do $get_color 'term8')
color9  #(do $get_color 'term9')
color10 #(do $get_color 'term10')
color11 #(do $get_color 'term11')
color12 #(do $get_color 'term12')
color13 #(do $get_color 'term13')
color14 #(do $get_color 'term14')
color15 #(do $get_color 'term15')
"

    # 3. Сохраняем и обновляем
    $kitty_conf | save -f $dest_path
    
    try { ^killall -SIGUSR1 kitty }
    print $"Theme updated from ($src_path)"
}
