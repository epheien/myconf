#!/bin/bash

[ -e ~/.pi/ ] && exit

ln -sv $(dirname "$(realpath .)") ~/.pi
