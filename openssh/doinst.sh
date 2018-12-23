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

config etc/rc.d/rc.sshd.new
config etc/pam.d/sshd.new
config etc/default/sshd.new

# If the sshd user/group/shadow don't exist, add them:

if ! grep -q "^sshd:" etc/passwd ; then
  echo "sshd:x:33:33:sshd:/:" >> etc/passwd
fi

if ! grep -q "^sshd:" etc/group ; then
  echo "sshd::33:sshd" >> etc/group
fi

if ! grep -q "^sshd:" etc/shadow ; then
  echo "sshd:*:9797:0:::::" >> etc/shadow
fi


mv etc/ssh/ssh_config.new etc/ssh/ssh_config
mv etc/ssh/sshd_config.new etc/ssh/sshd_config

# Add a btmp file to store login failure if one doesn't exist:
if [ ! -r var/log/btmp ]; then
  ( cd var/log ; umask 077 ; touch btmp )
fi

if [ -x bin/systemctl ]; then
  chroot . /bin/systemctl --system daemon-reload >/dev/null 2>&1
  # Enable sshd in systemd
  chroot . /bin/systemctl enable sshd.socket
  chroot . /bin/systemctl start sshd.socket
fi
