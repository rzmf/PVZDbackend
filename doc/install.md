# PVZD Backend system installation instructions

## git client
The master repository resides on the frontend system. It is a bare Git repository.

The sync between the local and remote git is a step in the cron job that is
calling PEP, pyFF and the sync.


## HSM/pyFF config
Config the key name in md_aggregate_sign.fd to match the key name on the HSM.
(See sign -> key)


## PEP
Install the source repository from github into opt/ before runnig docker build:
cd opt
git clone https://github.com/rhoerbe/PVZDpolman