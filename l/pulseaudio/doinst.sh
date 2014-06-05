#!/bin/sh
function free_user_id {
  # Find a free user-ID >= 120 (should be < 1000 so it's not a normal user)
  local FREE_USER_ID=100
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
if ! grep --quiet '^pulse:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
            -g $(free_group_id) \
            pulse 2> /dev/null
fi
if ! grep --quiet '^pulse-rt:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
            -g $(free_group_id) \
            pulse-rt 2> /dev/null
fi
if ! grep --quiet '^pulse-access:' etc/group ;then
  ${CHROOT} /usr/sbin/groupadd \
            -g $(free_group_id) \
            pulse-access 2> /dev/null
fi

# Set up user: add it if it doesn't exist, update it if it already does.
if OLD_ENTRY=$(grep --max-count=1 '^pulse:' etc/passwd) \
  || OLD_ENTRY=$(grep --max-count=1 \
  ':/var/run/pulse:[a-z/]*$' etc/passwd)
then
  # Modify existing user
  OLD_USER=$(echo ${OLD_ENTRY} | cut --fields=1 --delimiter=':')
  USER_ID=$(echo ${OLD_ENTRY} | cut --fields=3 --delimiter=':')
  test ${USER_ID} -ge 1000 && USER_ID=$(free_user_id)
  if test "${OLD_USER}" = "pulse"; then
    echo -n "Updating unprivileged user" 1>&2
  else
    echo -ne "Changing unprivileged user \e[1m${OLD_USER}\e[0m to" 1>&2
  fi
  ${CHROOT} /usr/sbin/usermod \
            -d /var/run/pulse \
            -u ${USER_ID} \
            -s /bin/false \
            -g pulse \
            ${OLD_USER}
else
  # Add new user
  echo -n "Creating unprivileged user" 1>&2
  ${CHROOT} /usr/sbin/useradd \
           -d /var/run/pulse \
           -c "PulseAudio daemon" \
           -u $(free_user_id) \
           -s /bin/false \
           -g pulse \
           pulse
fi

# Add ld.so.conf.d directory to /etc/ld.so.conf:
if fgrep ld.so.conf.d etc/ld.so.conf 1> /dev/null 2> /dev/null ; then
  true
else
  echo 'include /etc/ld.so.conf.d/*.conf' >> etc/ld.so.conf
fi

# Fix permissions
${CHROOT} /bin/chown pulse.pulse /var/run/pulse
${CHROOT} /bin/chown pulse.pulse /var/lib/pulse
${CHROOT} /bin/chmod 0700 /var/lib/pulse

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

