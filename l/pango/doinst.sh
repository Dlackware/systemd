# Updating the pango.modules file:
chroot . /sbin/ldconfig 2> /dev/null
if [ -x /usr/bin/update-pango-querymodules ]; then
  /usr/bin/update-pango-querymodules
fi
