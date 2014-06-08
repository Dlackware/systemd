#!/bin/sh

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
    mv ${NEW}.incoming ${NEW}
  fi
  # Don't use config() -- we always want to install this, changed or unchanged.
  #config ${NEW}
}

if [ ! -e var/log/httpd ]; then
  mkdir -p var/log/httpd
  chmod 755 var/log/httpd
fi

# Don't wipe out an existing document root:
if [ ! -L srv/www -a -d srv/www ]; then
  mv srv/www srv/www.bak.$$
fi
if [ ! -L srv/httpd -a -d srv/httpd ]; then
  mv srv/httpd srv/httpd.bak.$$
fi

# Once again, our intent is not to wipe out anyone's
# site, but building in Apache's docs tree is not as
# good an idea as picking a unique DocumentRoot.
#
# Still, we will do what we can here to mitigate
# possible site damage:
if [ -r var/www/htdocs/index.html ]; then
  if [ ! -r "var/log/packages/httpd-*upgraded*" ]; then
    if [ var/www/htdocs/index.html -nt var/log/packages/httpd-*-? ]; then
      cp -a var/www/htdocs/index.html var/www/htdocs/index.html.bak.$$
    fi
  fi
fi

# Keep same perms when installing rc.httpd.new:
preserve_perms etc/rc.d/rc.httpd.new
# Always install the new rc.httpd:
mv etc/rc.d/rc.httpd.new etc/rc.d/rc.httpd

# Handle config files.  Unless this is a fresh installation, the
# admin will have to move the .new files into place to complete
# the package installation, as we don't want to clobber files that
# may contain local customizations.
config etc/httpd/httpd.conf.new
config etc/logrotate.d/httpd.new
for conf_file in etc/httpd/extra/*.new; do
  config $conf_file
done
config var/www/htdocs/index.html.new

setcaps () {
  if chroot . /sbin/setcap "${1}" "${3}" 2>/dev/null; then
    chroot . /bin/chmod "${2}" "${3}"
  fi
}

chroot . /bin/chown root.apache /usr/sbin/suexec
chroot . /bin/chmod 4510 /usr/sbin/suexec

setcaps 'cap_setuid,cap_setgid+pe' 'u-s' /usr/sbin/suexec

chroot . /bin/chown root.apache /run/httpd

if [ -x bin/systemctl ] ; then
  chroot . /bin/systemctl --system daemon-reload >/dev/null 2>&1
fi
