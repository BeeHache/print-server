#! /bin/sh

echo "Starting ..."
service inetutils-syslogd start
service dbus start
service avahi-daemon start
service cups-browsed start
service cups start

echo " ... running"
sleep infinity
