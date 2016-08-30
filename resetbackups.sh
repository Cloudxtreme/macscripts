#!/bin/bash

# usage: "sudo ./resetbackups.sh"
# deletes all time machine backups except the latest one, thus removing all history.
# the time machine storage must be mounted when the script runs.

[[ $EUID -ne 0 ]] && { echo "Error: Must run as root."; exit 1; }

computername="$(scutil --get ComputerName)"
cd "/Volumes/Time Machine Backups/Backups.backupdb/${computername}"
[ $? -ne 0 ] && { echo "Error: Unable to access Time Machine backup storage."; exit 1; }

ls

files=($(ls))

if [ ${#files[@]} -le 2 ]; then
	echo "Only one backup, skipping..."
	exit
fi

MAX=${#files[@]}
(( MAX = MAX - 2 ))
START=0
echo "* Backups to delete: $MAX"
while :; do
	(( NONZEROSTART = START + 1 ))
	echo ". ${NONZEROSTART}/${MAX}: ${files[$START]}"
	tmutil delete "${files[$START]}"
	if [ $? -ne 0 ]; then
		# error happened, or user pressed Ctrl+C
		echo "Aborting..."
		break
	fi

	(( START = START + 1 ))
	if [ $START -ge $MAX ]; then
		break
	fi
done
