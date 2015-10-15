set -e -o pipefail

SBO_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SBO_PATCHDIR}/${PKGNAM}.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.2.0-redhat-modules.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.1.0-console-nochmod.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.1.0-notally.patch
#patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.2.0-faillock.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.1.6-noflex.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.1.5-limits-user.patch
#patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.1.8-full-relro.patch
# Upstreamed partially
#patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.1.8-pwhistory-helper.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.2.0-use-elinks.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/pam-1.1.8-audit-user-mgmt.patch

# Set to YES if autogen is needed
SB_AUTOGEN=YES

set +e +o pipefail
