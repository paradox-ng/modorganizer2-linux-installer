#!/usr/bin/env bash

f4se_config_dir="$game_installation/Data/F4SE"

mkdir -p "$f4se_config_dir"

cat << EOT >> "$f4se_config_dir/F4SE.ini"
[Loader]
RuntimeName=_Fallout4VR.exe
EOT