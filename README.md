# PVZD Backend

The PVZD Backend implementes a secure metadata signing servicebased on following
components:
* PVZD/PEP (Policy Enforcement Point) - loading SAML entitiy descriptors from git
* pyFF (Metadata Aggregator) - generating and signing SAML metadata
* SafeNet eToken Pro: HSM providing an PKCS#11 interface for pyFF

The Dockerfile was used to test the configuration. Alternatively there is a
script-based installation for a bare-metal deployment