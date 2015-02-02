
set -e -o pipefail

SBO_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SBO_PATCHDIR}/${PKGNAM}.patch
### Fedora
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.12.1-pam.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.12-selinux-label.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.12-ksu-path.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.12-ktany.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.12-buildconf.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.3.1-dns.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.10-kprop-mktemp.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.3.4-send-pr-tempfile.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.12-api.patch
#patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.10-doublelog.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.10-kpasswd_tcp.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.11-dirsrv-accountlock.patch
patch -p0 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.9-debuginfo.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-kvno-230379.patch
patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-1.11-kpasswdtest.patch
#patch -p1 -E --backup --verbose -i ${SBO_PATCHDIR}/krb5-master-keyring-kdcsync.patch

# Set to YES if autogen is needed
SBO_AUTOGEN=YES

set +e +o pipefail
