#! /bin/fish

set -l emojis \
    ":)" ":D" ":P" "^-^" "*-*" ">_<" "\$_\$" \
    ">:(" ":O" "O.O" o_O T_T ";)" ">:)" \
    "@_@" "B)" "B-)" ">:D" x_x ":3" \
    "(^_^)" "(>_<)" "(-_-)"

echo $emojis[$(math "($(date +%s) % $(count $emojis)) + 1")]
