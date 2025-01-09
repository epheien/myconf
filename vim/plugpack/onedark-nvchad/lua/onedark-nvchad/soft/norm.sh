#!/bin/bash

stylua --indent-type=Spaces --indent-width=2 *.lua
ls -1 *.lua | xargs -n 1 -I _ sort _ -o _
