#!/usr/bin/env bash

# Execure the backend system process chain:
# 1. pull requests
# 2. run PEP
# 3. run pyff
# 4. push results

cd /var/lib/git/pvmd
git pull
