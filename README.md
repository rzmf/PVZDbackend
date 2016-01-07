# PVZD Backend

The PVZD Backend implements a secure metadata signing servicebased on following
components:
* PVZD/PEP (Policy Enforcement Point) - loading SAML entitiy descriptors from git
* pyFF (Metadata Aggregator) - generating and signing SAML metadata
* Gemalto/SafeNet eToken Pro: HSM providing an PKCS#11 interface for pyFF
  http://www.safenet-inc.de/data-protection/authentication/etoken-pro

The Dockerfile was used to test the configuration. Alternatively there is a
script-based installation for a bare-metal deployment.

The mgmt_sys directory contains a docker project to build an image management
workstation for the eToken Pro that should be run on an isolated system.
 
