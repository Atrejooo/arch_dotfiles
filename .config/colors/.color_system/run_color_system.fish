#!/usr/bin/fish

cd $HOME/.config/colors
set targets ./.targets
./.color_system/color_replacer.py $COLOR_THEME $targets
