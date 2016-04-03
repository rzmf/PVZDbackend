#!/usr/bin/env bash

# PEPOUTDIR & MD_REPO need to be edited in the pyff config file (md_aggregate_sign.fd) as well

PEPOUTDIR='/var/lib/pepout/'

if [[ "$hostname" == "pvzdbe9" ]]; then
    # FRONTENDHOST=  passed from docker run
    MD_REPO='/var/lib/git/pvmd'
    PROJ_HOME='/opt/PVZDbackend/opt/PVZDpolman'
    PYFF_ROOT='/opt/pyff'
elif [[ "$ostype" == "linux" ]]; then
    #  RHEL6
    FRONTENDHOST='vmdev9013.adv.magwien.gv.at'
    MD_REPO='/var/lib/git/pvmd'
    PYKCS11PIN='secret1'
    PROJ_HOME='/home/gal/pvpmeta/PVZDbackend/opt/PVZDpolman'
    PYFF_ROOT='/home/gal/pvpmeta/PVZDbackend/opt/pyff'
else
    echo "no environment defined for $ostype and $(hostname)"
    exit 1
fi
