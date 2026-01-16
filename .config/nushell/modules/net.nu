export def myip []: nothing -> record<ip: string> {
    curl -s https://ipwho.is | from json | update timezone {update current_time {into datetime} | update offset {into duration --unit sec}}
}

