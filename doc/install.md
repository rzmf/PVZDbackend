# PVZD Backend system installation instructions

## git client
The master repository (git init --bare) resides on the frontend system.
TODO: ssh-keys for client

The sync between the local and remote git is a step in the cron job that is
calling PEP, pyFF and the sync.

The git repository is located in /var/lib/git/pvmd


## HSM/pyFF config
Config the key name in md_aggregate_sign.fd to match the key name on the HSM.
(See the line with 'sign -> key')
Provide the 

## PEP
### PEP Installation
Install the source repositories from github into opt/ before runnig docker build:
cd opt
git clone https://github.com/rhoerbe/PVZDjava
git clone https://github.com/rhoerbe/PVZDpolman

Resolve the dependencies within PVZDpolman 

### PVZD Configuration

Set environent variables before starting docker with run.sh:
    FRONTENDHOST
    PYKCS11PIN  (if using the HSM)

Configure pyff: 
    Copy a default file to md_aggregate_sign.fd and edit the settings 

Enable ssh/git access on frontend system:
    precondition: create account backend@$FRONTEND has been created
    if not done already, create ssh client key, like:
        ssh-keygen -t ecdsa
    add local ssh public key to backend@$FRONTEND:~.ssh/authorized_keys
