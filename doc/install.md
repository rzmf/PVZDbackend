# PVZD Backend system installation instructions

## git client
The master repository (git init --bare) resides on the frontend system.

The sync between the local and remote git is a step before and after execusing PEP:
/usr/local/bin/run_pep.sh

The git repository is located in /var/lib/git/pvmd

## PEP
### PEP Installation
Install the source repositories from github into opt/ before runnig docker build:
cd opt
git clone https://github.com/rhoerbe/PVZDjava
git clone https://github.com/rhoerbe/PVZDpolman

Resolve the dependencies within PVZDpolman 

### PVZD Configuration
Directires and env variables are configured in $PROJ_ROOT/conf.sh.
Set environent variable FRONTENDHOST in conf.sh before starting docker with run.sh.
    
Enable ssh/git access on frontend system:
- gen ssh-keys for client, if they do not exist yet (.ssh mapped to docker host)
    
    docker exec -it pvzdbe9 /opt/scripts/gen_sshkey.sh
    
- Create account for user backend on frontend host
 
- Authorize ssh key on the frontend host (add local ssh public key to backend@$FRONTEND:~.ssh/authorized_keys)

### Execute PEP
PEP should be run on a frequent basis to provide responses on uploads before long, e.g. every 30s.
