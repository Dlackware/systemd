config() {
  NEW="$1"
  OLD="`dirname $NEW`/`basename $NEW .new`"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
for file in etc/cups/*.new ; do
  config $file
done

config etc/dbus-1/system.d/cups.conf.new
config etc/pam.d/cups.new

# This file will just have to go.  It appeared for a while during a -current
# devel period and has never been part of a stable release.
#config etc/modprobe.d/cups.blacklist.usblp.conf.new
rm -f etc/modprobe.d/cups.blacklist.usblp.conf.new
rm -f etc/modprobe.d/cups.blacklist.usblp.conf

# Leave any new rc.cups with the same permissions as the old one:
# This is a kludge, but it's because there's no --reference option
# on busybox's 'chmod':
if [ -e etc/rc.d/rc.cups ]; then
  if [ -x etc/rc.d/rc.cups ]; then
    chmod 755 etc/rc.d/rc.cups.new
  else
    chmod 644 etc/rc.d/rc.cups.new
  fi
fi
# Then config() it:
config etc/rc.d/rc.cups.new

if [ -x bin/systemctl ] ; then
  /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
