#!/usr/bin/env sh

# Load our config file
# shellcheck source=./backup.conf.sh
. "$1"

cd "$BACKUP_DIR" || exit 1

restic backup . 1>/dev/null 2>&1
backup_exit_code=$?

case $backup_exit_code in
    0) echo "SUCCESS: Backup created successfully"  ;;
    1) echo "ERROR: Fatal error during backup";     exit 1;;
    3) echo "ERROR: Inconsistent snapshot created"; exit 3;;
    10) echo "ERROR: Repository does not exist";    exit 10;;
    11) echo "ERROR: Repository is locked";         exit 11;;
    12) echo "ERROR: Incorrect password";           exit 12;;
    *) echo "ERROR: Unknown error type";            exit 1
esac
