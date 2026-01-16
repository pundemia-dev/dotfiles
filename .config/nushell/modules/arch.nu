def show_updates [] {
    # --- Pacman ---
    # Сохраняем в переменную с вашим шаблоном и collect
    let pac_updates = (do -i { ^checkupdates } | parse "{name} {from}->{to}" | collect)
    
    # Выводим заголовок
    print $"    󰮯 Pacman packages (($pac_updates | length)):"
    
    # Выводим таблицу, если она не пустая
    if not ($pac_updates | is-empty) {
        print $pac_updates
    }

    # --- Yay ---
    # Используем ваш шаблон "{package}..." и collect
    let yay_updates = (do -i { ^yay -Qua } | parse "{package} {from}->{to}" | collect)
    
    # Выводим заголовок
    print $"\n     Yay packages (($yay_updates | length)):"
    
    # Выводим таблицу
    if not ($yay_updates | is-empty) {
        print $yay_updates
    }
}
