
systemctl enable update-pango-querymodules.service
systemctl enable update-gio-modules.service
systemctl enable update-gdk-pixbuf-loaders.service
systemctl enable glib-compile-schemas.service
systemctl enable gdm.service

systemctl set-default graphical.target

if [ -x bin/systemctl ] ; then
  . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi

