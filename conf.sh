#!/usr/bin/env bash

# configure container
export IMGID=9
export IMAGENAME="rhoerbe/pvzdbe"
export CONTAINERNAME="pvzdbe${IMGID}"
export CONTAINERUSER="pvzdbe${IMGID}"   # group and user to run container
export CONTAINERUID="800${IMGID}"        # gid and uid for CONTAINERUSER
export BUILDARGS="
    --build-arg USERNAME=$CONTAINERUSER
    --build-arg UID=$CONTAINERUID
"
export ENVSETTINGS="
    -e DISPLAY=$DISPLAY
    -e FRONTENDHOST=$FRONTENDHOST
    -e PYKCS11PIN=secret1
    -e USERNAME=$CONTAINERUSER
"
export NETWORKSETTINGS="
    --privileged -v /dev/bus/usb:/dev/bus/usb
"
export VOLROOT="/docker_volumes/$CONTAINERNAME"  # container volumes on docker host
export VOLMAPPING="
    -v $VOLROOT/pepout/:/var/lib/pepout/:Z
    -v $VOLROOT/git/:/var/lib/git/:Z
    -v $VOLROOT/log/pvzd:/var/log/pvzd:Z
"
export STARTCMD='/start.sh'

# create user/group host directories if not existing
if ! id -u $CONTAINERUSER &>/dev/null; then
    groupadd -g $CONTAINERUID $CONTAINERUSER
    adduser -M -g $CONTAINERUID -u $CONTAINERUID $CONTAINERUSER
fi

# create dir with given user if not existing, relative to $HOSTVOLROOT; set/repair ownership
function chkdir {
    dir=$1
    user=$2
    mkdir -p "$VOLROOT/$dir"
    chown -R $user:$user "$VOLROOT/$dir"
}

# Check runtime evironment
chkdir git/ $CONTAINERUSER
chkdir log/pvzd/ $CONTAINERUSER
chkdir pyff/config/ $CONTAINERUSER

export FRONTENDHOST=pvzdfe10

# Prepare the build envirionment
if [ ! -d 'opt/PVZDpolman' ]; then
    mkdir -p opt/PVZDpolman
    git clone https://github.com/rhoerbe/PVZDpolman opt/PVZDpolman
    cd PVZDpolman/dependent_pkg
    if [[ "$ostype" == "darwin" ]]; then
        mkdir benson-basis && git clone https://github.com/benson-basis/pyjnius.git benson-basis/pyjnius
        ln -s benson-basis/pyjnius pyjnius
    else
        mkdir kivy && git clone https://github.com/kivy/pyjnius.git kivy/pyjnius
        ln -s kivy/pyjnius pyjnius
    fi
    mkdir -p rhoerbe/json2html && git clone https://github.com/rhoerbe/json2html.git rhoerbe/json2html
    ln -s rhoerbe/json2html json2html
    #curl -O https://pypi.python.org/packages/source/o/ordereddict/ordereddict-1.1.tar.gz
    #tar -xzf ordereddict-*.tar.gz
    cd ../..
fi

