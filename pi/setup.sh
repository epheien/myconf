#!/bin/bash
# curl -fsSL https://pi.dev/install.sh | sh
# npm install -g --ignore-scripts @earendil-works/pi-coding-agent

script_path=$(realpath "$0")
script_dir=$(dirname "$script_path")

[ -e ~/.pi/ ] && exit

ln -sv "$script_dir" ~/.pi
