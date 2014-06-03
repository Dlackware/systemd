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
if ! grep --quiet '^polkitd:' etc/group ;then
  /usr/sbin/groupadd \
    -g $(free_group_id) \
    polkitd 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^polkitd:' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "polkitd"; then
    echo -n "Updating unprivileged user " 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  /usr/sbin/usermod \
      -d '/' \
      -u ${USER_ID} \
      -s /bin/false \
      -g polkitd \
      ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user " 1>&2
  /usr/sbin/useradd \
    -c 'User for polkitd' \
    -u $(free_user_id) \
    -g polkitd \
    -s /bin/false \
    -d '/' \
    polkitd 2> /dev/null
fi

# Fix permissions
/bin/chown polkitd.root /etc/polkit-1/rules.d
/bin/chown polkitd.root /usr/share/polkit-1/rules.d

if [ -x bin/systemctl ] ; then
  /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
