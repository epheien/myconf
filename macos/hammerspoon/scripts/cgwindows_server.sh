#!/bin/bash

if [ -e ~/.venv/ ]; then
    source ~/.venv/bin/activate
fi

exec ~/.hammerspoon/scripts/cgwindows_server.py "$@"
