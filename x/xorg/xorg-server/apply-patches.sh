
set -e -o pipefail

DLACK_PATCHDIR=${CWD}/patches

unset PATCH_DRYRUN_OPT PATCH_VERBOSE_OPT

[ "${PATCH_DRYRUN}" = "YES" ] && PATCH_DRYRUN_OPT="--dry-run"
[ "${PATCH_VERBOSE}" = "YES" ] && PATCH_VERBOSE_OPT="--verbose"
[ "${PATCH_SVERBOSE}" = "YES" ] && set -o xtrace

PATCHCOM="patch ${PATCH_DRYRUN_OPT} -p1 -F1 -s ${PATCH_VERBOSE_OPT}"

ApplyPatch() {
  local patch=$1
  shift
  if [ ! -f ${DLACK_PATCHDIR}/${patch} ]; then
    exit 1
  fi
  echo "Applying ${patch}"
  case "${patch}" in
  *.bz2) bzcat "${DLACK_PATCHDIR}/${patch}" | ${PATCHCOM} ${1+"$@"} ;;
  *.gz) zcat "${DLACK_PATCHDIR}/${patch}" | ${PATCHCOM} ${1+"$@"} ;;
  *) ${PATCHCOM} ${1+"$@"} -i "${DLACK_PATCHDIR}/${patch}" ;;
  esac
}

# patch -p0 --verbose -i ${SB_PATCHDIR}/${NAME}.patch
ApplyPatch x11.startwithblackscreen.diff

### Fedora

# This really could be done prettier.
ApplyPatch xserver-1.4.99-ssh-isnt-local.patch

# ajax needs to upstream this
ApplyPatch xserver-1.6.99-right-of.patch

ApplyPatch 0001-Always-install-vbe-and-int10-sdk-headers.patch

# misc
ApplyPatch 0001-Fix-segfault-when-killing-X-with-ctrl-alt-backspace.patch

ApplyPatch xserver-force-hal-disable.patch

### Arch
# Use nouveau/nv/nvidia drivers for nvidia devices
ApplyPatch autoconfig-nvidia.patch

# Set to YES if autogen is needed
DLACK_AUTOGEN=YES

set +e +o pipefail
