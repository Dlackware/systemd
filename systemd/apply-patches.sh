patch -p0 -E --backup --verbose -i $CWD/patches/udev-microsoft-3000-keymap.patch

# From Slackware
patch -p0 -E --backup --verbose -i $CWD/patches/60-cdrom_id.rules.diff
patch -p1 -E --backup --verbose -i $CWD/patches/Don-t-enable-audit-by-default.patch
