#!/usr/bin/env bash

# configure container
export IMGID=1
export IMAGENAME="rhoerbe/pvzdmgmgsystem"
export CONTAINERNAME="pvzdmgmgsystem${IMGID}"
export CONTAINERUSER="admin"     # group and user to run container
export CONTAINERUID="800${IMGID}"   # gid and uid for CONTAINERUSER
export BUILDARGS="
    --build-arg USERNAME=$CONTAINERUSER \
    --build-arg UID=$CONTAINERUID \
"
export ENVSETTINGS="
    -e USERNAME=$CONTAINERUSER
"
export NETWORKSETTINGS="
"
export VOLROOT="/docker_volumes/$CONTAINERNAME"  # container volumes on docker host
export VOLMAPPING="
    -v $VOLROOT/log/:/var/log/:Z
"
export STARTCMD='/start.sh'

# first create user/group/host directories if not existing
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
chkdir log/ $CONTAINERUSER

