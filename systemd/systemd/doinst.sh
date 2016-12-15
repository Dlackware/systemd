# Figure out our root directory
ROOTDIR=$(pwd)
unset CHROOT
if test "${ROOTDIR}" != "/"; then
  CHROOT="chroot ${ROOTDIR} "
  ROOTDIR="${ROOTDIR}/"
fi
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

# Keep same perms on rc.udev.new:
if [ -r etc/rc.d/rc.udev -a -r etc/rc.d/rc.udev.new ]; then
  chmod --reference=etc/rc.d/rc.udev etc/rc.d/rc.udev.new
fi

## List of conf files to check.  The conf files in your package should end in .new
config etc/locale.conf.new
config etc/machine-id.new
config etc/machine-info.new
config etc/pam.d/systemd-user.new
config etc/rc.d/rc.local_shutdown.new
config etc/rc.d/rc.udev.new
config etc/rc.d/rc.Msystemd.new
config etc/systemd/journald.conf.new
config etc/systemd/logind.conf.new
config etc/systemd/resolved.conf.new
config etc/systemd/system.conf.new
config etc/systemd/timesyncd.conf.new
config etc/systemd/user.conf.new
config etc/vconsole.conf.new
config var/lib/systemd/catalog/database.new

rm -f etc/locale.conf.new
rm -f etc/machine-id.new
rm -f etc/machine-info.new
rm -f etc/vconsole.conf.new
rm -f var/lib/systemd/catalog/database.new

function free_user_id {
  # Find a free user-ID >= 100 (should be < 1000 so it's not a normal user)
  local FREE_USER_ID=100
  while grep --quiet "^.*:.*:${FREE_USER_ID}:.*:.*:.*:" etc/passwd; do
    let FREE_USER_ID++
  done
  echo ${FREE_USER_ID}
}
function free_group_id {
  # Find a free group-ID >= 120 (should be < 1000 so it's not a normal group)
  local FREE_GROUP_ID=100
  while grep --quiet "^.*:.*:${FREE_GROUP_ID}:" etc/group; do
    let FREE_GROUP_ID++
  done
  echo ${FREE_GROUP_ID}
}

# Set up groups.
if ! grep --quiet '^lock:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    lock 2> /dev/null
fi
if ! grep --quiet '^systemd-journal:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-journal 2> /dev/null
fi
if ! grep --quiet '^systemd-journal-gateway:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-journal-gateway 2> /dev/null
fi
if ! grep --quiet '^systemd-journal-remote:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-journal-remote 2> /dev/null
fi
if ! grep --quiet '^systemd-journal-upload:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-journal-upload 2> /dev/null
fi

if ! grep --quiet '^systemd-timesync:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-timesync 2> /dev/null
fi

if ! grep --quiet '^systemd-network:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-network 2> /dev/null
fi

if ! grep --quiet '^systemd-resolve:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-resolve 2> /dev/null
fi

if ! grep --quiet '^systemd-bus-proxy:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    systemd-bus-proxy 2> /dev/null
fi

if ! grep --quiet '^input:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
    -g $(free_group_id) \
    input 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^systemd-journal-gateway:' etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/log/journal:[a-z/]*$' etc/passwd)
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
  ${CHROOT} /usr/sbin/usermod \
      -d '/var/log/journal' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-journal-gateway \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  ${CHROOT} /usr/sbin/useradd \
    -c 'Journal Gateway' \
    -u $(free_user_id) \
    -g systemd-journal-gateway \
    -s /bin/false \
    -d '/var/log/journal' \
    systemd-journal-gateway 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^systemd-journal-remote:' etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/log/journal/remote:[a-z/]*$' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "systemd-journal-remote"; then
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to " 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
      -d '/var/log/journal/remote' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-journal-remote \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  ${CHROOT} /usr/sbin/useradd \
    -c 'Journal Remote' \
    -u $(free_user_id) \
    -g systemd-journal-remote \
    -s /bin/false \
    -d '/var/log/journal/remote' \
    systemd-journal-remote 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^systemd-journal-upload:' etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/log/journal/upload:[a-z/]*$' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "systemd-journal-upload"; then
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to " 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
      -d '/var/log/journal/upload' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-journal-upload \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  ${CHROOT} /usr/sbin/useradd \
    -c 'Journal Upload' \
    -u $(free_user_id) \
    -g systemd-journal-upload \
    -s /bin/false \
    -d '/var/log/journal/upload' \
    systemd-journal-upload 2> /dev/null
fi

if OLD_ENTRY=$(grep --max-count=1 '^systemd-timesync:' etc/passwd)
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
  ${CHROOT} /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-timesync \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  ${CHROOT} /usr/sbin/useradd \
    -c 'systemd Time Synchronization' \
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
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to " 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-network \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  ${CHROOT} /usr/sbin/useradd \
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
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to " 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-resolve \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  ${CHROOT} /usr/sbin/useradd \
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
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to " 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
      -d '/var/lib/systemd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g systemd-bus-proxy \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  ${CHROOT} /usr/sbin/useradd \
    -c 'systemd Bus Proxy' \
    -u $(free_user_id) \
    -g systemd-bus-proxy \
    -s /bin/false \
    -d '/var/lib/systemd' \
    systemd-bus-proxy 2> /dev/null
fi

enableservice () {
  if ! ${CHROOT} /bin/systemctl is-enable "${1}" > /dev/null 2>&1 ;then
    ${CHROOT} /bin/systemctl enable "${1}" 2>&1
  fi
}

# Try to read default runlevel from the old inittab if it exists
runlevel=$(${CHROOT} /bin/awk -F':' '$3 == "initdefault" && $1 !~ "^#" { print $2 }' /etc/inittab 2> /dev/null)
if [ -z "${runlevel}" ]; then
  target="/lib/systemd/system/graphical.target"
else
  target="/lib/systemd/system/runlevel${runlevel}.target"
fi

# And symlink what we found to the new-style default.target
${CHROOT} /bin/ln -sf "${target}" /etc/systemd/system/default.target

if [ -r lib/systemd/systemd ]; then
  mv -f lib/systemd/systemd lib/systemd/systemd.old
fi

mv -f lib/systemd/systemd.new lib/systemd/systemd

if [ -f lib/systemd/systemd.old ]; then
  rm -f lib/systemd/systemd.old
fi

if [ ! -r etc/systemd/system/syslog.service ] ;then
  ${CHROOT} /bin/ln -s /lib/systemd/system/rsyslog.service /etc/systemd/system/syslog.service >/dev/null 2>&1 || :
fi

enableservice getty@tty1.service || :
enableservice remote-fs.target || :
#enableservice systemd-readahead-replay.service || :
#enableservice systemd-readahead-collect.service || :

${CHROOT} /bin/systemd-machine-id-setup > /dev/null 2>&1 || :
${CHROOT} /lib/systemd/systemd-random-seed save >/dev/null 2>&1 || :
${CHROOT} /bin/systemctl daemon-reexec > /dev/null 2>&1 || :
sleep 1

${CHROOT} /bin/systemctl stop systemd-udevd-control.socket systemd-udevd-kernel.socket systemd-udevd.service >/dev/null 2>&1 || :
${CHROOT} /bin/systemctl --system daemon-reload  >/dev/null 2>&1 || :
${CHROOT} /bin/systemctl start systemd-udevd.service >/dev/null 2>&1 || :
${CHROOT} /sbin/udevadm hwdb --update >/dev/null 2>&1 || :
${CHROOT} /bin/journalctl --update-catalog >/dev/null 2>&1 || :
${CHROOT} /bin/systemd-tmpfiles --create >/dev/null 2>&1 || :

if [ -f etc/nsswitch.conf ] ; then
  ${CHROOT} sed -i.bak -e '
    /^hosts:/ !b
    /\<myhostname\>/ b
    s/[[:blank:]]*$/ myhostname/
    ' /etc/nsswitch.conf >/dev/null 2>&1 || :
fi

# Make sure new journal files will be owned by the "systemd-journal" group
${CHROOT} /bin/chgrp systemd-journal /run/log/journal/ >/dev/null 2>&1 || :
${CHROOT} /bin/chgrp systemd-journal /run/log/journal/$(cat /etc/machine-id) >/dev/null 2>&1 || :
${CHROOT} /bin/chgrp systemd-journal /var/log/journal/ >/dev/null 2>&1 || :
${CHROOT} /bin/chgrp systemd-journal /var/log/journal/$(cat /etc/machine-id) >/dev/null 2>&1 || :
${CHROOT} /bin/chmod g+s /var/log/journal/ >/dev/null 2>&1 || :
${CHROOT} /bin/chmod g+s /var/log/journal/$(cat /etc/machine-id) >/dev/null 2>&1 || :

${CHROOT} /usr/bin/setfacl -Rnm g:adm:rx,d:g:adm:rx /var/log/journal/ >/dev/null 2>&1 || :

# Move old stuff around in /var/lib
${CHROOT} mv /var/lib/random-seed /var/lib/systemd/random-seed >/dev/null 2>&1 || :
${CHROOT} mv /var/lib/backlight /var/lib/systemd/backlight >/dev/null 2>&1 || :

