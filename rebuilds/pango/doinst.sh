# Updating the pango.modules file:
chroot . /sbin/ldconfig 2> /dev/null

systemctl enable update-pango-querymodules.service

if [ -x /usr/bin/update-pango-querymodules ]; then
  /usr/bin/update-pango-querymodules
fi

systemctl enable update-pango-querymodules.service
