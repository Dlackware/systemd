#!/bin/sh
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
config etc/rc.d/rc.samba.new
config etc/samba/lmhosts.new
# This won't be needed.  The point here is to preserve the permissions of the existing
# file, if there is one.  I don't see major new development happening in rc.samba...  ;-)
rm -f etc/rc.d/rc.samba.new
