#!/usr/bin/env bash

# Execute the backend system process chain every 10 minutes:
# 1. pull requests
# 2. run PEP
# 3. run pyff
# 4. push results

SCRIPTDIR=$(cd $(dirname $BASH_SOURCE[0]) && pwd)
source $SCRIPTDIR/conf.sh

# Intialize new container
if [ -d "${PEPOUTDIR}" ] &&
cd ${PEPOUTDIR}
git clone ssh://backend@${FRONTENDHOST}/${PEPOUTDIR}

#BASEDIR='/usr/local/pyFF'
LOGDIR='/var/log/pvzd'
LOGLEVEL='INFO'
PIPELINEBATCH="${PYFF_ROOT}/config/md_aggregate_sign.fd"

# Note: Within Docker a daemon does not make much sense. However, if installed
# without Docker, make sure to to disconnect stdin, stdout # and stderr, and
# ignore SIGHUP before backgrounding the process, or start pyff from cron


while true
do
    cd ${PEPOUTDIR} && git pull

    cd "${PROJ_HOME}/PolicyManager/bin" && ./PEP.sh
    pyff --loglevel=$LOGLEVEL $PIPELINEBATCH

    cd ${PEPOUTDIR} && git push
    sleep 600
done