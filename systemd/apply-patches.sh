SBO_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SBO_PATCHDIR}/${NAME}.patch
patch -p0 -E --backup --verbose -i ${SBO_PATCHDIR}/udev-microsoft-3000-keymap.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/meson-options-debug.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/detect-statx.patch

# From Slackware
patch -p0 -E --backup --verbose -i ${SBO_PATCHDIR}/60-cdrom_id.rules.diff
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/Don-t-enable-audit-by-default.patch
