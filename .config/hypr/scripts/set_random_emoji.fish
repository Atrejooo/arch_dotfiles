#! /bin/fish

function set_random_emoji
    set -l emojis \
        ":)" ":D" ":P" "^-^" "*-*" ">_<" "\$_\$" \
        ">:(" ":O" "O.O" o_O T_T ";)" ">:)" \
        "@_@" "B)" "B-)" ">:D" x_x ":3" \
        "(^_^)" "(>_<)" "(-_-)"

    set -l random_index (random 1 (count $emojis))
    set -x RAND_EMOJI $emojis[$random_index]
end

set_random_emoji

while true
    sleep 60
    set_random_emoji
end
