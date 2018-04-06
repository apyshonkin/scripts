#!/bin/bash
# Simple backup script for dockerized PostgreSQL
# Maintainer: Aleksey Pyshonkin
# Mail: alex@pyshonk.in

while getopts ":n:p:f:" option; do
    case $option in
            n ) CONTAINER_NAME=${OPTARG:-postgres};;
            p ) PG_PORT=${OPTARG:-5432};;
            f ) BACKUP_NAME=${OPTARG:-`mktemp XXXXXX`};;
            * ) echo "[!] Invalid option" && usage && exit 1;;
    esac
done
shift "$((OPTIND-1))"

function usage() {
    cat <<EOF
Usage:
    pg_docker_backup [-n CONTAINER_NAME] [-p PORT] 

Options:
        -n CONTAINER_NAME       name of the container to seek. If not set, we shall probe the corresponding port.
        -p PORT                 port of the container. Note that it must be available for host machine (e.g. EXPOSEd or the container run with --network=host option).
        -f FILE                 override backup filename. If not set, randomized name will be used instead.
EOF
}

PG_CONTAINER=`docker ps -a | grep $CONTAINER_NAME | awk '{ print $11 }'`
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm)
BACKUP_FILENAME="${BACKUP_NAME}_$TIMESTAMP.sql.gz"

# check if sudo is necessary
function sudocheck() {
if [ "$(whoami)" != "root" ]; 
then
	if id | grep docker; 
	then
		echo hui
		#if sudo -ll | grep -e 'ALL|docker';
                #then DOCKER_CMD=$(which sudo) $(which docker)
                #else echo "No either sudo available or user is not in docker group. Please fix one of these." && exit -1
                #fi
	else
		echo pizda
		#DOCKER_CMD=`which docker`
	fi
fi
}

function log() {
        while read line; do
                if [ x"$IM" == x"1" ]; then
                        echo "$line" | tee -a "$LOG_FILE"
                else
                        echo "$line" >> "$LOG_FILE"
                fi
        done
}

function backup() {
	${DOCKER_CMD} exec -t ${PG_CONTAINER} pg_dumpall -c -U postgres | gzip > ${BACKUP_FILENAME}
}

function mailer() {
echo "TO-DO. Not implemented so far."
}

#backup
sudocheck

