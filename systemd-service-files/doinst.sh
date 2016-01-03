
systemctl set-default graphical.target

systemctl enable update-gdk-pixbuf-loaders.service
systemctl enable gdm.service

if [ -x bin/systemctl ] ; then
  . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi

