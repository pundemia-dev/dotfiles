def h1 [text: string] {
    ^figlet -f starwars $text | ^tee /dev/tty | wl-copy
}

def h2 [text: string] {
    ^figlet -f standard $text | ^tee /dev/tty | wl-copy
}

def h3 [text: string] {
    ^figlet -f small $text | ^tee /dev/tty | wl-copy
}

def h4 [text: string] {
    ^figlet -f straight $text | ^tee /dev/tty | wl-copy
}

def h5 [text: string] {
    ^figlet -f short $text | ^tee /dev/tty | wl-copy
}
