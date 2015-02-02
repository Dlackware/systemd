
set -e -o pipefail

SBO_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SBO_PATCHDIR}/${PKGNAM}.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/nm-applet-no-notifications.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/nm-applet-wifi-dialog-ui-fixes.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/applet-ignore-deprecated.patch

set +e +o pipefail
