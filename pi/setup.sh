#!/bin/bash
# npm install -g --ignore-scripts @earendil-works/pi-coding-agent

script_path=$(realpath "$0")
script_dir=$(dirname "$script_path")

[ -e ~/.pi/ ] && exit

ln -sv "$script_dir" ~/.pi
