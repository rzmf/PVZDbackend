# PVZD Backend: PEP

## Overview

The PVZD Backend implements a secure metadata signing service based on following
components:
* PVZD/PEP (Policy Enforcement Point) - loading SAML entitiy descriptors from git
* pyFF (Metadata Aggregator) - generating and signing SAML metadata
* Gemalto/SafeNet eToken Pro: HSM providing an PKCS#11 interface for pyFF
  http://www.safenet-inc.de/data-protection/authentication/etoken-pro
* git/ssh to pull data from and push data to the front-end system

This project provides the container for the PEP component

