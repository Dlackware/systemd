#!/bin/bash

# Once slacktrack has determined what the contents of the package
# should be, it copies them into $SLACKTRACKFAKEROOT
# From here we can make modifications to the package's contents
# immediately prior to the invocation of makepkg: slacktrack will
# do nothing else with the contents of the package after the execution
# of this script.

# If you modify anything here, be careful *not* to include the full
# path name - only use relative paths (ie rm usr/bin/foo *not* rm /usr/bin/foo).

# Enter the package's contents:
cd $SLACKTRACKFAKEROOT

# OpenSP creates this symlink; we delete it.
if [ -L usr/share/doc ]; then
   rm -f usr/share/doc
fi

# Incase you had CUPS running:
rm -rf etc/cups etc/printcap
# crond & mail (just incase you got a delivery!)
rm -rf var/spool/{cron,mail}
rmdir var/spool

# perllocal.pod files don't belong in packages.
# SGMLSPL creates this:
find . -name perllocal.pod -print0 | xargs -0 rm -f

# Some doc dirs have attracted setuid.
# We don't need setuid for anything in this package:
chmod -R a-s .

# Remove dangling symlinks from /usr/doc.  asciidoc-8.6.7 was a culprit.
find usr/doc -xtype l -print0 | xargs -0 rm -fv

# Ensure some permissions.  
# I don't know why but these dirs are installed chmod 1755:
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/pk/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/pk/ljfour/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/pk/ljfour/jknappen/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/pk/ljfour/jknappen/ec/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/source/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/source/jknappen/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/source/jknappen/ec/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/tfm/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/tfm/jknappen/
#drwxr-xr-t root/root         0 2006-05-27 15:42:44 var/lib/texmf/tfm/jknappen/ec/
#find var/lib/texmf -type d -print0 | xargs -0 chmod 755
# This directory needs these permissions to permit pleb accounts to make
# fonts:
#chmod 1777 var/lib/texmf
# 
# Never mind: I think this stuff is surplus to requirements:
rm -rf var/lib/texmf
# Now to prevent deletion of anything else that lives in the package's '/var'
rmdir var/lib
rmdir var

# There's no reason to include huge redundant documentation:
cd usr/doc
find . -name "*.txt" | while read docfile ; do
  basedocname=$(echo $docfile | rev | cut -f 2- -d . | rev)
  rm -fv ${basedocname}.{html,pdf,xml}
  rm -fv docbook-xsl*/reference.pdf.gz
done

# Now you should manually extract the .tgz 
# - check through the install/doinst.sh script;
# - check the contents, permissions and ownerships in the package archive.
