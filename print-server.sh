#!/bin/sh

NAME="print-server"
PWD="$( cd "$(dirname "$0")" ; pwd -P )"
BASENAME=`basename -s .sh $0`
CONF="${PWD}/cupsd.conf"
CID_FILE="${PWD}/${BASENAME}.cid"
VOLUME="${NAME}-data"

build() {
	docker build -t beehache/$NAME .
}

start() {
	docker run -d --rm -p $1:631 -v $VOLUME:/var/spool/cups -v $CONF:/etc/cups/cupsd.conf:ro beehache/$NAME > $CID_FILE
}

stop() {
	local cid=`cat $CID_FILE`
	[ -f $CID_FILE ] && docker container stop $cid && rm $CID_FILE
}

usage() {
	echo "Usage : $BASENAME [-s | --start] PORT | [-S | --stop] | [-b | --build]"
}

case $1 in
	'-b' | '--build')
		build
		;;

	'-S' | '--stop')
		stop
		;;

	'-s' | '--start')
		if [ -z $2 ]; then
			usage
		else 
			start $2
		fi
		;;
	*)
		usage
esac
