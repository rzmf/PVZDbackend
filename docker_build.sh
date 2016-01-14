#!/usr/bin/env bash


if [ ! -d 'opt/PVZDpolman' ]; then
    cd opt && git clone https://github.com/rhoerbe/PVZDpolman
fi

docker build -t=pvzdbe .