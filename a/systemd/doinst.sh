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

# Keep same perms on rc.udev.new:
if [ -r /etc/rc.d/rc.udev -a -r /etc/rc.d/rc.udev.new ]; then
  chmod --reference=/etc/rc.d/rc.udev /etc/rc.d/rc.udev.new
fi

## List of conf files to check. The conf files in your package should end in .new

config /etc/rc.d/rc.local_shutdown.new
config /etc/rc.d/rc.udev.new
config /etc/vconsole.conf.new
config /etc/locale.conf.new
config /etc/machine-id.new
config /etc/machine-info.new
config /var/lib/systemd/catalog/database.new
config /etc/systemd/bootchart.conf.new
config /etc/systemd/journald.conf.new
config /etc/systemd/logind.conf.new
config /etc/systemd/system.conf.new
config /etc/systemd/user.conf.new

function free_user_id {
  # Find a free user-ID >= 100 (should be < 1000 so it's not a normal user)
  local FREE_USER_ID=120
  while grep --quiet "^.*:.*:${FREE_USER_ID}:.*:.*:.*:" /etc/passwd ; do
    let FREE_USER_ID++
  done
  echo ${FREE_USER_ID}
}

function free_group_id {
  # Find a free group-ID >= 120 (should be < 1000 so it's not a normal group)
  local FREE_GROUP_ID=120
  while grep --quiet "^.*:.*:${FREE_GROUP_ID}:" /etc/group ; do
    let FREE_GROUP_ID++
  done
  echo ${FREE_GROUP_ID}
}

# Set up groups.
if ! grep --quiet '^lock:' /etc/group ;then
  /usr/sbin/groupadd \
    -g $(free_group_id) \
    lock 2> /dev/null
fi

if ! grep --quiet '^systemd-journal:' /etc/group ;then
  /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-journal 2> /dev/null
fi

if ! grep --quiet '^systemd-journal-gateway:' /etc/group ;then
  /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-journal-gateway 2> /dev/null
fi

if ! grep --quiet '^systemd-timesync:' /etc/group ;then
  /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-timesync 2> /dev/null
fi

if ! grep --quiet '^systemd-network:' /etc/group ;then
  /usr/sbin/groupadd \
     -g $(free_group_id) \
     systemd-network 2> /dev/null
fi

if ! grep --quiet '^systemd-resolve:' /etc/group ;then
  /usr/sbin/groupadd \
     -g $(free_group_id) \
     systemd-resolve 2> /dev/null
fi

if ! grep --quiet '^systemd-bus-proxy:' /etc/group ;then
  /usr/sbin/groupadd \
     -g $(free_group_id) \
     systemd-bus-proxy 2> /dev/null
fi

if ! grep --quiet '^input:' etc/group ;then
  /usr/sbin/groupadd \
     -g $(free_group_id) \
     input 2> /dev/null
fi


# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^systemd-journal-gateway:' /etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/log/journal:[a-z/]*$' /etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "systemd-journal-gateway"; then
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to " 1>&2
  fi
  /usr/sbin/usermod \
      -d '/var/log/journal' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-journal-gateway \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  /usr/sbin/useradd \
    -c 'Journal Gateway' \
    -u $(free_user_id) \
    -g systemd-journal-gateway \
    -s /bin/false \
    -d '/var/log/journal' \
    systemd-journal-gateway 2> /dev/null
fi

if OLD_ENTRY=$(grep --max-count=1 '^systemd-timesync:' /etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/lib/systemd:[a-z/]*$' /etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "systemd-timesync"; then
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to " 1>&2
  fi
  /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-timesync \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  /usr/sbin/useradd \
    -c 'Systemd Timesync' \
    -u $(free_user_id) \
    -g systemd-timesync \
    -s /bin/false \
    -d '/var/lib/systemd' \
    systemd-timesync 2> /dev/null
fi

if OLD_ENTRY=$(grep --max-count=1 '^systemd-network:' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "systemd-network"; then
    echo -n "Updating unprivileged user" 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-network \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  /usr/sbin/useradd \
    -c 'systemd Network Management' \
    -u $(free_user_id) \
    -g systemd-network \
    -s /bin/false \
    -d '/var/lib/systemd' \
    systemd-network 2> /dev/null
fi

if OLD_ENTRY=$(grep --max-count=1 '^systemd-resolve:' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "systemd-resolve"; then
    echo -n "Updating unprivileged user" 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-resolve \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  /usr/sbin/useradd \
    -c 'systemd Resolver' \
    -u $(free_user_id) \
    -g systemd-resolve \
    -s /bin/false \
    -d '/var/lib/systemd' \
    systemd-resolve 2> /dev/null
fi

if OLD_ENTRY=$(grep --max-count=1 '^systemd-bus-proxy:' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "systemd-bus-proxy"; then
    echo -n "Updating unprivileged user" 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-bus-proxy \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  /usr/sbin/useradd \
    -c 'systemd Bus Proxy' \
    -u $(free_user_id) \
    -g systemd-bus-proxy \
    -s /bin/false \
    -d '/var/lib/systemd' \
    systemd-bus-proxy 2> /dev/null
fi




setcaps () {
  if /sbin/setcap "${1}" "${3}" 2>/dev/null; then
    /bin/chmod "${2}" "${3}"
  fi
}

enableservice () {
  if ! /bin/systemctl is-enable "${1}" > /dev/null 2>&1 ;then
    /bin/systemctl enable "${1}" 2>&1
  fi
}

# And symlink what we found to the new-style default.target
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

# Lets make sure DNS resolve works
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

if [ -r /lib/systemd/systemd ]; then
  mv -f /lib/systemd/systemd /lib/systemd/systemd.old
fi

mv -f /lib/systemd/systemd.new /lib/systemd/systemd

if [ -f /lib/systemd/systemd.old ]; then
  rm -f /lib/systemd/systemd.old
fi

if [ ! -r /etc/systemd/system/syslog.service ] ;then
  ln -s /lib/systemd/system/rsyslog.service /etc/systemd/system/syslog.service >/dev/null 2>&1 || :
fi

enableservice getty@tty1.service || :
enableservice remote-fs.target || :
enableservice systemd-readahead-replay.service || :
enableservice systemd-readahead-collect.service || :
enableservice systemd-networkd.service || :

setcaps 'cap_dac_override,cap_sys_ptrace+ep' 'u-s' /usr/bin/systemd-detect-virt

/bin/systemd-machine-id-setup > /dev/null 2>&1 || :
/lib/systemd/systemd-random-seed save >/dev/null 2>&1 || :
/bin/systemctl daemon-reexec > /dev/null 2>&1 || :
sleep 1

/bin/systemctl stop systemd-udev.service systemd-udev-control.socket systemd-udev-kernel.socket >/dev/null 2>&1 || :
/bin/systemctl --system daemon-reload >/dev/null 2>&1 || :
/bin/systemctl start systemd-udev.service >/dev/null 2>&1 || :
/sbin/udevadm hwdb --update >/dev/null 2>&1 || :
/bin/journalctl --update-catalog >/dev/null 2>&1 || :
/bin/systemd-tmpfiles --create >/dev/null 2>&1 || :

if [ -f /etc/nsswitch.conf ] ; then
  sed -i.bak -e '
    /^hosts:/ !b
    /\<myhostname\>/ b
    s/[[:blank:]]*$/ myhostname/
    ' /etc/nsswitch.conf >/dev/null 2>&1 || :
fi

# Make sure new journal files will be owned by the "systemd-journal" group
/bin/chgrp systemd-journal /var/log/journal/ >/dev/null 2>&1 || :
/bin/chgrp systemd-journal /var/log/journal/$(cat /etc/machine-id) >/dev/null 2>&1 || :
/bin/chmod g+s /var/log/journal/ >/dev/null 2>&1 || :
/bin/chmod g+s /var/log/journal/$(cat /etc/machine-id) >/dev/null 2>&1 || :

/usr/bin/setfacl -Rnm g:adm:rx,d:g:adm:rx /var/log/journal/ >/dev/null 2>&1 || :

ln -sf /proc/self/mounts /etc/mtab >/dev/null 2>&1 || :
