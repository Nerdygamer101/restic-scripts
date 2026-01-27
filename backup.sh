#!/usr/bin/env sh

while getopts "Z:NcL:d:" flag; do
    case "$flag" in
        Z) echo "Z $OPTARG";;
        N) echo "Nice enabled :)"; nice=19;;
        c) compression=max;;
        L) bw_limit=$OPTARG;;
        d) conf_dirs="$OPTARG\n$conf_dirs";;
        *) echo "Invalid flag: $OPTARG"; exit 1
    esac
done


echo "$conf_dirs"
# Load our config file
for conf in "$PWD"/*.conf.sh; do
    echo "Found: $conf"
done

################################################################################
# Takes one argument, a backup configuration file.
################################################################################
backup() (
# shellcheck source=./backup.conf.sh
. "$1"

cd "$BACKUP_DIR" || exit 1

nice -n "${nice:-0}" \
restic backup \
    --no-scan=true \
    --compression="${compression:-auto}" \
    --limit-download="${bw_limit:-0}" \
    --limit-upload="${bw_limit:-0}" \
    --quiet=true \
    . 1>/dev/null 2>&1
backup_exit_code=$?

case $backup_exit_code in
    0) echo "SUCCESS: Backup created successfully"  ;;
    1) echo "ERROR: Fatal error during backup";     exit 1;;
    3) echo "ERROR: Inconsistent snapshot created"; exit 3;;
    10) echo "ERROR: Repository does not exist";    exit 10;;
    11) echo "ERROR: Repository is locked";         exit 11;;
    12) echo "ERROR: Incorrect password";           exit 12;;
    126) echo "ERROR: Could not execute restic";    exit 126;;
    127) echo "ERROR: restic not found";            exit 127;;
    *) echo "ERROR: Unknown error type";            exit 1
esac
)
