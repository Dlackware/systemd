systemd
=======

systemd for Slackware

These slackbuilds are provided to compile systemd on top of Stock Slackware.
There are 2 directories [systemd] and [rebuilds]

[systemd] is what we think should be minimal recompiled in order to have a minimal functional Slackware that runs systemd, this includes pam.
[rebuilds] consist of recompiled packages that should benefit from systemd.

Both set of packages are needed if you want to build gnome-systemd

Both directories have compile-order files
in used with the dlackware script, it will download, compile, install the packaes from that list

I would like to thank the following persons for the information needed for the slackbuilds.
Patrick Volkerding, Alien_bob, rworkman, Vincent Batts, Niels Horn and https://github.com/PhantomX
