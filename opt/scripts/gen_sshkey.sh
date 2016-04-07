#!/usr/bin/env bash

ssh-keygen -t ECDSA -f ~/.ssh/id_ecdsa -N ''
if [ -z ~/.ssh/config ]; then
    echo "Host frontendhost" > ~/.ssh/config
    echo "HostName $FRONTENDHOST" >> ~/.ssh/config
    echo "Port FRONTEND_SSHPORT" >> ~/.ssh/config
fi