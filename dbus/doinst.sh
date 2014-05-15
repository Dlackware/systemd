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

config etc/rc.d/rc.messagebus.new
config etc/dbus-1/session.conf.new
config etc/dbus-1/system.conf.new

# Keep same perms on rc.messagebus.new:
if [ -r etc/rc.d/rc.messagebus -a -r etc/rc.d/rc.messagebus.new ]; then
  chmod --reference=etc/rc.d/rc.messagebus etc/rc.d/rc.messagebus.new
fi

# Fix some ownership
chroot . /bin/chown root.messagebus /lib/dbus-1/dbus-daemon-launch-helper
chroot . /bin/chmod 4750 /lib/dbus-1/dbus-daemon-launch-helper
chroot . /bin/chown messagebus.root /var/lib/dbus

if [ -x bin/systemctl ] ; then
  chroot . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
