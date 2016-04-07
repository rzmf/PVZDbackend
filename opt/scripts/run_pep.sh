#!/usr/bin/env bash

# Execute the backend system process chain every 10 minutes:
# 1. pull requests
# 2. run PEP
# 3. push results

# Intialize new container
if [ ! -d "${PEPOUTDIR}" ]; then
    echo "First time use: initialize repository"
    cd /var/lib/git
    git clone ssh://backend@$FRONTENDHOST/var/lib/git/pvmd
fi

cd $MD_REPO && git pull
cd $PROJ_HOME/PolicyManager/bin && ./PEP.sh
cd $MD_REPO && git push
