#!/bin/bash

selected_app=$(ls /usr/share/applications/ | fzf --style=minimal --color='
                       hl:magenta hl+:magenta
                       pointer:magenta marker:magenta
                       header:blue
                       current-bg:#223344
                       spinner:cyan info:cyan
                       prompt:blue query:magenta
                       border:blue
                       label:magenta
                     ' --border=sharp --padding=0 --margin=5%,25%,5%,25% --border-label="@ Prime Runner @")

if [[ -n "$selected_app" ]]; then
    prime-run uwsm app -- "$selected_app" "$@" > /dev/null 2> /dev/null & disown
fi
