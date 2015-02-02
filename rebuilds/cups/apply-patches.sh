
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

# patch -p0 -E --backup --verbose -i ${SB_PATCHDIR}/${NAME}.patch
ApplyPatch cups-no-gzip-man.patch
ApplyPatch cups-system-auth.patch
ApplyPatch cups-multilib.patch
ApplyPatch cups-banners-slk.patch
ApplyPatch cups-serverbin-compat.patch
ApplyPatch cups-no-export-ssllibs.patch
ApplyPatch cups-direct-usb.patch
ApplyPatch cups-lpr-help.patch
ApplyPatch cups-peercred.patch
ApplyPatch cups-pid.patch
ApplyPatch cups-eggcups.patch
ApplyPatch cups-driverd-timeout.patch
ApplyPatch cups-strict-ppd-line-length.patch
ApplyPatch cups-logrotate.patch
ApplyPatch cups-usb-paperout.patch
ApplyPatch cups-res_init.patch
ApplyPatch cups-filter-debug.patch
ApplyPatch cups-uri-compat.patch
ApplyPatch cups-str3382.patch
ApplyPatch cups-0755.patch
ApplyPatch cups-hp-deviceid-oid.patch
ApplyPatch cups-dnssd-deviceid.patch
ApplyPatch cups-ricoh-deviceid-oid.patch
ApplyPatch cups-systemd-socket.patch
ApplyPatch cups-lpd-manpage.patch
ApplyPatch cups-avahi-address.patch
ApplyPatch cups-usblp-quirks.patch
ApplyPatch cups-enum-all.patch
ApplyPatch cups-dymo-deviceid.patch
ApplyPatch cups-use-ipp1.1.patch
ApplyPatch cups-no-gcry.patch
ApplyPatch cups-avahi-no-threaded.patch
ApplyPatch cups-ipp-multifile.patch
ApplyPatch cups-web-devices-timeout.patch
ApplyPatch cups-final-content-type.patch
ApplyPatch cups-journal.patch
ApplyPatch cups-synconclose.patch

## SECURITY PATCHES:

set +e +o pipefail
