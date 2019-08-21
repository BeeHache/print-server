#!/bin/sh

VERSION=0.0.1
PWD="$( cd "$(dirname "$0")" ; pwd -P )"
BASENAME=`basename -s .sh $0`
NAME=$BASENAME
DATA_VOLUME="${NAME}-data"
CONF_VOLUME="${NAME}-conf"

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
		-v $DATA_VOLUME:/var/spool/cups \
		-v $CONF_VOLUME:/etc/cups \
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
	echo "Usage : ${BASENAME}.sh [-s | start] | [-S | stop] | [-b | build] | [[-e | exec] ...]"
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
	*)
		usage
esac
