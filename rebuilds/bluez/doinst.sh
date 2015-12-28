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

# Keep same perms on rc.bluetooth.new:
if [ -e etc/rc.d/rc.bluetooth ]; then
  cp -a etc/rc.d/rc.bluetooth etc/rc.d/rc.bluetooth.new.incoming
  cat etc/rc.d/rc.bluetooth.new > etc/rc.d/rc.bluetooth.new.incoming
  mv etc/rc.d/rc.bluetooth.new.incoming etc/rc.d/rc.bluetooth.new
fi

config etc/rc.d/rc.bluetooth.new
config etc/bluetooth/input.conf.new
config etc/bluetooth/main.conf.new
config etc/bluetooth/network.conf.new
config etc/bluetooth/proximity.conf.new
config etc/bluetooth/rfcomm.conf.new
config etc/bluetooth/uart.conf.new
config etc/default/bluetooth.new

