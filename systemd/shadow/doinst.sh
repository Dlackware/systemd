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

for i in etc/pam.d/*.new ; do
    config $i
done

config etc/default/useradd.new

config var/log/faillog.new
rm -f var/log/faillog.new

mv /etc/login.defs /etc/login.defs.old
mv /etc/login.defs.new /etc/login.defs

config etc/default.useradd.new
