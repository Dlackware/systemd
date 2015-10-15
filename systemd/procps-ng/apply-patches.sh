
set -e -o pipefail

DLACK_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SB_PATCHDIR}/${NAME}.patch
# Display the location from which the user is logged in by default.
# This is how previous versions of 'w' in Slackware have always
# defaulted.
patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/procps.w.showfrom.diff 
patch -p0 -E --backup --verbose -i ${DLACK_PATCHDIR}/procps-3.3.9-systemd209.patch

# Set to YES if autogen is needed
DLACK_AUTOGEN=YES

set +e +o pipefail
