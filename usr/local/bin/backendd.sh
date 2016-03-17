#!/usr/bin/env bash

# Execute the backend system process chain every 10 minutes:
# 1. pull requests
# 2. run PEP
# 3. run pyff
# 4. push results

# Intialize new container
cd /var/lib/git
git clone ssh://backend@$FRONTENDHOST/var/lib/git/pvmd

BASEDIR='/usr/local/pyFF'
LOGDIR='/var/log/pvzd'
LOGLEVEL='INFO'
PIPELINEBATCH='/home/gal/pvpmeta/PVZDbackend/opt/pyff/config/md_aggregate_sign.fd'
export PYKCS11PIN='secret1'


# Note: Within Docker a daemon does not make sense. However, if installed
# without Docker, make sure to to disconnect stdin, stdout # and stderr, and
# ignore SIGHUP before backgrounding the process


while true
do
    cd /var/lib/git/pvmd && git pull
    #cd /opt/PVZDpolman/PolicyManager/bin && ./PEP.sh
    cd /home/gal/pvpmeta/PVZDbackend/opt/PVZDpolman/PolicyManager/bin && ./PEP.sh
    #/var/virtualenv/pyff/bin/pyff \
    pyff \
        --loglevel=$LOGLEVEL $PIPELINEBATCH

    cd /var/lib/git/pvmd && git push
    sleep 600
done