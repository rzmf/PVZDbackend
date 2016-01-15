#!/usr/bin/env bash

# Execure the backend system process chain:
# 1. pull requests
# 2. run PEP
# 3. run pyff
# 4. push results

# 1.
cd /var/lib/git/pvmd
git pull


#2.
cd /opt/PVZDpolman/PolicyManager/bin

