#!/bin/sh

PWD="$( cd "$(dirname "$0")" ; pwd -P )"
BASENAME=`basename -s .sh $0`
NAME=$BASENAME
CONF="${PWD}/conf"
LOGS="${PWD}/logs"
INITLOG="${PWD}/init.log"
VOLUME="${NAME}-data"

cmd() {
     	sudo docker container exec -t -i $NAME $*
}

build() {
	sudo docker build -t beehache/$NAME .
}

start() {
	mkdir -p $LOGS
	touch $INITLOG
	sudo docker run -d \
		--rm \
		--name $NAME \
		-p 161:161/udp \
		-p 161:161/tcp \
		-p 162:162/udp \
		-p 162:162/tcp \
		-p 631:631/udp \
		-p 631:631/tcp \
		-p 137:137/udp \
		-p 137:137/tcp \
		-p 139:139/udp \
		-p 139:139/tcp \
		-p 445:445/udp \
		-p 445:445/tcp \
		-p 5353:5353/udp \
		-p 5353:5353/tcp \
		--network host \
		-v $VOLUME:/var/spool/cups \
		-v $CONF:/etc/cups \
		-v $LOGS:/var/log \
		-v $INITLOG:/app/init-log \
		beehache/$NAME
}

stop() {
	sudo docker container stop $NAME
}


usage() {
	echo "Usage : ${BASENAME}.sh [-s | --start] | [-S | --stop] | [-b | --build] | [[-e | --exec] ...]"
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
