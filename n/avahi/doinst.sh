function free_user_id {
  # Find a free user-ID >= 100 (should be < 1000 so it's not a normal user)
  local FREE_USER_ID=120
  while grep --quiet "^.*:.*:${FREE_USER_ID}:.*:.*:.*:" etc/passwd; do
    let FREE_USER_ID++
  done
  echo ${FREE_USER_ID}
}
function free_group_id {
  # Find a free group-ID >= 120 (should be < 1000 so it's not a normal group)
  local FREE_GROUP_ID=120
  while grep --quiet "^.*:.*:${FREE_GROUP_ID}:" etc/group; do
    let FREE_GROUP_ID++
  done
  echo ${FREE_GROUP_ID}
}

# Figure out our root directory
ROOTDIR=$(pwd)
unset CHROOT
if test "${ROOTDIR}" != "/"; then
 CHROOT="chroot ${ROOTDIR} "
  ROOTDIR="${ROOTDIR}/"
fi

# Set up groups.
if ! grep --quiet '^avahi:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
            -g $(free_group_id) \
            avahi 2> /dev/null
fi
if ! grep --quiet '^avahi_autoipd:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
            -g $(free_group_id) \
            avahi-autoipd 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^avahi:' etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/etc/avahi:[a-z/]*$' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "avahi"; then
    echo -n "Updating unprivileged user" 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
            -d '/etc/avahi' \
            -u ${USER_ID} \
            -s /bin/false \
            -g avahi \
            ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  ${CHROOT} /usr/sbin/useradd \
            -c 'Avahi daemon' \
            -u $(free_user_id) \
            -g avahi \
            -s /bin/false \
            -d '/etc/avahi' \
            avahi 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^avahi_autoipd:' etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/lib/avahi_autoipd:[a-z/]*$' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "avahi_autoipd"; then
    echo -n "Updating unprivileged user" 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
            -d '/var/lib/avahi_autoipd' \
            -u ${USER_ID} \
            -s /bin/false \
            -g avahi_autoipd \
            ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  ${CHROOT} /usr/sbin/useradd \
            -c 'avahi_autoipd' \
            -u $(free_user_id) \
            -g avahi_autoipd \
            -s /bin/false \
            -d '/var/lib/avahi_autoipd' \
            avahi_autoipd 2> /dev/null
fi

if [ -s /etc/localtime ]; then
  cp -fp /etc/localtime etc/avahi/etc/localtime
fi

config() {
  NEW="\$1"
  OLD="\$(dirname \$NEW)/\$(basename \$NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r \$OLD ]; then
    mv \$NEW \$OLD
  elif [ "\$(cat \$OLD | md5sum)" = "\$(cat \$NEW | md5sum)" ]; then
    # toss the redundant copy
    rm \$NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
## List of conf files to check. The conf files in your package should end in .new

# Fix permissions
${CHROOT} /bin/chown avahi.avahi /var/run/avahi-daemon

if [ -x bin/systemctl ] ; then
  ${CHROOT} /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
