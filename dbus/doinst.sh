config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

# Keep same perms on rc.messagebus.new:
if [ -e etc/rc.d/rc.messagebus ]; then
  cp -a etc/rc.d/rc.messagebus etc/rc.d/rc.messagebus.new.incoming
  cat etc/rc.d/rc.messagebus.new > etc/rc.d/rc.messagebus.new.incoming
  mv etc/rc.d/rc.messagebus.new.incoming etc/rc.d/rc.messagebus.new
fi

#config etc/rc.d/rc.messagebus.new
# No, just install the thing.  Leaving it as .new will only lead to problems.
if [ -r etc/rc.d/rc.messagebus.new ]; then
  mv etc/rc.d/rc.messagebus.new etc/rc.d/rc.messagebus
fi

if [ -x bin/systemctl ] ; then
  chroot . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
