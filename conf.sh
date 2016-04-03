#!/usr/bin/env bash

# configure container
export IMGID=9
export IMAGENAME="rhoerbe/pvzdbe"
export CONTAINERNAME="pvzdbe${IMGID}"
export CONTAINERUSER="admin"        # group and user to run container
export CONTAINERUID="800${IMGID}"   # gid and uid for CONTAINERUSER
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
    -v $VOLROOT/pyff/config:/opt/pyff/config/:Z
"
export STARTCMD='/start.sh'

# create user/group host directories if not existing
if [ ! id -u $CONTAINERUSER &>/dev/null ]; then
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

if [[ ! "$FRONTENDHOST" ]];  then echo "need to set FRONTENDHOST"; exit 1; fi

# Prepare the build envirionment
if [ ! -d 'opt/PVZDpolman' ]; then
    cd opt && git clone https://github.com/rhoerbe/PVZDpolman
    cd PVZDpolman/dependent_pkg
    mkdir YAmikep && cd YAmikep && git clone https://github.com/YAmikep/json2html.git && cd ..
    ln -s YAmikep/json2html json2html
    mkdir benson-basis && cd benson-basis && git clone https://github.com/benson-basis/pyjnius.git && cd ..
    ln -s benson-basis/pyjnius pyjnius
    curl -O https://pypi.python.org/packages/source/o/ordereddict/ordereddict-1.1.tar.gz
    tar -xzf ordereddict-*.tar.gz
    cd ../../..
fi

