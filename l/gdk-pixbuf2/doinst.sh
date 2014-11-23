chroot . /usr/bin/update-gdk-pixbuf-loaders 1> /dev/null 2> /dev/null

if [ -x bin/systemctl ] ; then
  chroot . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
