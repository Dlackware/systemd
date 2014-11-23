# Reload .mount files:
PID=$(/sbin/pidof -o %PPID gvfsd)
if [ -n "${PID}" ] ;then
  kill -USR1 ${PID} >&/dev/null
fi

if [ -x usr/bin/update-desktop-database ]; then
  chroot . /usr/bin/update-desktop-database 1> /dev/null 2> /dev/null
fi

if [ -x usr/bin/gio-querymodules ] ; then
  chroot . /usr/bin/gio-querymodules @LIBDIR@/gio/modules &> /dev/null
fi

if [ -x /usr/bin/glib-compile-schemas ] ;then
  chroot . /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas &> /dev/null
fi
