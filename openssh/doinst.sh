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
preserve_perms() {
  NEW="$1"
  OLD="$(dirname ${NEW})/$(basename ${NEW} .new)"
  if [ -e ${OLD} ]; then
    cp -a ${OLD} ${NEW}.incoming
    cat ${NEW} > ${NEW}.incoming
    touch -r ${NEW} ${NEW}.incoming
    mv ${NEW}.incoming ${NEW}
  fi
  config ${NEW}
}

if [ -r etc/pam.d/sshd.new ]; then
  config etc/pam.d/sshd.new
fi
config etc/default/sshd.new
config etc/ssh/ssh_config.new
config etc/ssh/sshd_config.new
preserve_perms etc/rc.d/rc.sshd.new
if [ -e etc/rc.d/rc.sshd.new ]; then
  mv etc/rc.d/rc.sshd.new etc/rc.d/rc.sshd
fi

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
