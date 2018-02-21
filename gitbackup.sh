#!/bin/bash
# This script backs up our GitHub repos 

GITHUB_ORG=${FIXME}
GITHUB_USER=${FIXME}
GITHUB_PASSWORD=${FIXME}
GITHUB_API=${https://api.github.com}
GITHUB_CLONE_CMD="git clone --quiet git@github.com:"
BACKUP_DIR=/backup/github/${GITHUB_ORG}
REPOLIST=`curl --silent -u $GITHUB_USER:$GITHUB_PASSWORD https://api.github.com/orgs/c7s/repos\?per_page=100 | grep "\"name\"" | grep -v MIT | awk -F': "' '{print $2}' | sed -e 's/",//g'`
TSTAMP=`date "+%Y%m%d"`
PRUNE_DAYS=7

function timestamp {
        date +["%Y-%m-%d_%H-%M-%S"]
}

function backup {
        for REPO in $REPOLIST; do
                mkdir -p $BACKUP_DIR/$TSTAMP
                echo `timestamp` "Backing up & compressing ${GITHUB_ORG}/${REPO}"
                ${GITHUB_CLONE_CMD}${GITHUB_ORG}/${REPO}.git ${BACKUP_DIR}/$TSTAMP/${REPO} && tar czpPf ${BACKUP_DIR}/$TSTAMP/$REPO.tar.gz ${BACKUP_DIR}/$TSTAMP/${REPO} --remove-files
        done
}

function prune {
        find ${BACKUP_DIR}/$GITHUB_ORG -maxdepth 1 -type d -mtime +3 -exec rm -rf {} \;
}

echo `timestamp` "=== Starting GitHub repo backup ==="
mkdir -p $BACKUP_DIR

backup

echo "" && echo `timestamp` "=== DONE ===" && echo ""

echo "" && echo `timestamp` "=== Pruning backups older than $PRUNE_DAYS days." && echo ""

prune

echo `timestamp` "=== GitHub backup completed ===" && echo ""
