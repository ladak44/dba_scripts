#!/usr/bin/env bash


#set -o errexit
set -o nounset
#set -o xtrace

#######################################################################
# This script make a postgres database backup.
# It should be launched like postgres user with os authentication
# Default backup os user is postgres
# Backup is done in custom format
#
# Input parameter:
# 1.Database name
# 2.Backup localization
#
# eg:
# backup_psql.sh dbtest /backup
# Default retention period is 30 days
#
# eq:
# Restore database
#
# cat /tmp/dbtest.20190125.dump.gz | gunzip | pg_restore --dbname=restore
#
#######################################################################


# Setting up variables
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"
__date=`date +%Y%m%d`
__time=`date +"%Y-%m-%d %T"`
#__work_dir=${__root}
__work_dir='/tmp'
__state_file=${__work_dir}/state.file
__log_file=${__work_dir}/refresh.log
__retention_period=30
__backup_user="postgres"
__server_status=`pg_isready`
__compress_method='/bin/gzip'


(

_show_error() {
  local msg="$1"
   printf "=======================================\n"
   printf "\033[31m ${msg}\033[0m\n"
   printf "=======================================\n"
   exit 1
}

# check input parameter
if [ "$#" -ne 2 ]; then
   _show_error "Missing input parameters."
fi

__db_name=$1
__backup_dir=$2

# check backup user
if [ "$(id -un)" != ${__backup_user}  ]; then
   _show_error "Wrong backup user."
fi

# check if database is up
if [ "$?" -eq 0 ]; then
   __ret=$(psql -tAc "SELECT 1 FROM pg_database where datname='${__db_name}'")
   if [ ! ${__ret} ]; then
      _show_error "Database: ${__db_name} is down."
   fi
else
   _show_error "PostgreSQL server is not ready.\n ${__server_status}"
fi

# check if backup directory exsists
if [ ! -e ${__backup_dir} ]; then
   _show_error "Backup directory: ${__backup_dir} dosen't exsist."
fi

# backup file format
__backup_file=${__backup_dir}'/'${__db_name}.${__date}.dump.gz


printf "==========================================================\n"
printf "Time: ${__time} \n"
printf "Database name: ${__db_name} \n"
printf "Working directory: ${__work_dir} \n"
printf "Log file: ${__log_file} \n"
printf "Backup file: ${__backup_file}\n"
printf "==========================================================\n"

# remove previous backup
#if [ -e ${__backup_file} ]; then
#       rm ${__backup_file}
#fi

# Make a backup in cutom format (binary)
__ret=$(pg_dump -Fc  ${__db_name} | ${__compress_method} > ${__backup_file})

if [ ${__ret} ]; then
   _show_error "Problem with database backup."
fi

# remove backups older than retention period
find ${__backup_dir} -mtime +${__retention_period} -name '*bzip' -exec rm {} \;

printf "==========================================================\n"
printf "Time: ${__time} \n"
printf "\033[32mSUCCESS: All steps finished successfully. \033[0m\n"
printf "==========================================================\n"

) | tee -a ${__log_file}

