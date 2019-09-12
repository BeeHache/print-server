#!/bin/sh

VERSION=0.0.2
PWD="$( cd "$(dirname "$0")" ; pwd -P )"
BASENAME=`basename -s .sh $0`
NAME=$BASENAME
CUPS_DATA_VOLUME="${NAME}-data"
CUPS_CONF_VOLUME="${NAME}-conf"
CUPS_CACHE_VOLUME="${NAME}-cache"
CUPS_SHARE_VOLUME="${NAME}-share"
GCP_UTIL="/usr/bin/gcp-connector-util"
GCP_CONF_VOLUME="${NAME}-gcp-conf"
GCP_CONF_DIR="/etc/gcp"
GCP_CONF_FILE="$GCP_CONF_DIR/gcp-cups-connector.config.json"

cmd() {
     	sudo docker container exec -t -i $NAME $*
}

build() {
	sudo docker build -t beehache/$NAME:$VERSION .
}

start() {
	sudo docker run -d \
		--rm \
		--name $NAME \
		--hostname $NAME \
		--network host \
		-v $CUPS_DATA_VOLUME:/var/spool/cups \
		-v $CUPS_CONF_VOLUME:/etc/cups \
		-v $CUPS_CACHE_VOLUME:/var/cache/cups \
		-v $CUPS_SHARE_VOLUME:/usr/share/cups \
		-v $GCP_CONF_VOLUME:$GCP_CONF_DIR \
		beehache/$NAME:$VERSION
}

stop() {
	sudo docker container stop $NAME
}

restart() {
	stop
	start
}


usage() {
	echo "Usage : ${BASENAME}.sh [-s | start] | [-S | stop] | [-b | build] | [[-e | exec] ...] | [shell ...] | gcp-config"
}

case $1 in
	'-b' | 'build')
		build
		;;

	'-S' | 'stop')
		stop
		;;

	'-s' | 'start')
		start
		;;
	'-e' | 'exec')
		shift 
		cmd $@
		;;
	'shell')
		cmd /bin/bash
		;;
	'gcp-config')
		cmd $GCP_UTIL --config-filename $GCP_CONF_FILE init;
		cmd $GCP_UTIL --config-filename $GCP_CONF_FILE backfill-config-file;
		cmd chown cloud-print-connector:cloud-print-connector $GCP_CONF_FILE;
		cmd service gcp restart
		;;
	'update')
		cmd /tools/copy_dropfiles.sh
		cmd service cups restart
		;;
	*)
		usage
esac
