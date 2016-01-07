#!/usr/bin/env sh

/bin/dbus-daemon --system || exit -1
/usr/sbin/hald --daemon=yes || exit -1
/usr/sbin/pcscd -c /etc/reader.conf || exit -1
