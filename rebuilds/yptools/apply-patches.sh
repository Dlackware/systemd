
set -e -o pipefail

DLACK_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${DLACK_PATCHDIR}/${NAME}.patch
### Slackware
patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/yp-tools-2.14-glibc217-crypt.diff

( cd ${YPBSRCDIR}
  cat ${DLACK_PATCHDIR}/ypbind-1.11-gettextdomain.patch | patch -p1 -E --backup --verbose
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypbind-mt-1.37.1-systemd209.patch
)

( cd ${YPSSRCDIR}
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypserv-2.21-path.patch
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypserv-2.13-ypxfr-zeroresp.patch
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypserv-2.13-nonedomain.patch
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypserv-2.19-slp-warning.patch
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypserv-2.24-manfix.patch
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypserv-2.24-aliases.patch
  patch -p1 -E --backup --verbose -i ${DLACK_PATCHDIR}/ypserv-2.31-systemd209.patch
)



# Set to YES if autogen is needed
DLACK_AUTOGEN=YES

set +e +o pipefail
