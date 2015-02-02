config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

config etc/gtk-2.0/gtkrc.new
config etc/gtk-2.0/im-multipress.conf.new
rm -f etc/gtk-2.0/gtkrc.new

chroot . rm -f /usr/share/icons/*/icon-theme.cache 1> /dev/null 2> /dev/null

# Run this if we are on an installed system.  Otherwise it will be
# handled on first boot.
if [ -x /usr/bin/update-gtk-immodules-2.0 ]; then
  /usr/bin/update-gtk-immodules
fi

# In case this is the first run installing the standalone gdk-pixbuf,
# we will run this a second time to fix machines that will not reboot.
chroot . /usr/bin/update-gdk-pixbuf-loaders 1> /dev/null 2> /dev/null

if [ -x bin/systemctl ] ; then
  chroot . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
