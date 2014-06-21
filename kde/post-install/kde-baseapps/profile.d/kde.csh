#!/bin/csh
# KDE additions:
if ( ! $?KDEDIRS ) then
    setenv KDEDIRS /usr
endif
setenv PATH ${PATH}:/usr/lib/kde4/libexec

if ( $?XDG_CONFIG_DIRS ) then
    setenv XDG_CONFIG_DIRS ${XDG_CONFIG_DIRS}:/etc/kde/xdg
else
    setenv XDG_CONFIG_DIRS /etc/xdg:/etc/kde/xdg
endif
