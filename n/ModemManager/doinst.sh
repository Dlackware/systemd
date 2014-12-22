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

if [ -x bin/systemctl ] ; then
 /bin/systemctl enable ModemManager >/dev/null 2>&1
fi

if [ -x bin/systemctl ] ; then
 /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi

