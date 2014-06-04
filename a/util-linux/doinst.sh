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
if ! grep --quiet '^uuidd:' /etc/group ;then
  chroot . /usr/sbin/groupadd \
    -g $(free_group_id) \
    uuidd 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^uuidd:' /etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/run/uuidd:[a-z/]*$' /etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "uuidd"; then
    echo -n "Updating unprivileged user" 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  chroot . /usr/sbin/usermod \
      -d '/run/uuidd' \
      -u ${USER_ID} \
      -s /bin/false \
      -g uuidd \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  chroot . /usr/sbin/useradd \
    -c 'UUID generator helper daemon' \
    -u $(free_user_id) \
    -g uuidd \
    -s /bin/false \
    -d '/run/uuidd' \
    uuidd 2> /dev/null
fi

# Fix permissions
chroot . /bin/chmod 4755 /bin/mount
chroot . /bin/chmod 4755 /bin/umount
chroot . /bin/chown root:tty /usr/bin/wall
chroot . /bin/chmod 2755 /usr/bin/wall
chroot . /bin/chown root:tty /usr/bin/write
chroot . /bin/chmod 2755 /usr/bin/write
chroot . /bin/chown uuidd:uuidd /usr/sbin/uuidd
chroot . /bin/chown uuidd:uuidd /run/uuidd
chroot . /bin/chmod 2775 /run/uuidd

if [ -x /bin/systemctl ] ; then
  chroot . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
