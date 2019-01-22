#!/usr/bin/env bash


#set -o errexit
set -o nounset
#set -o xtrace

#####################################################################################################################
# 
# replicat_ogr.sh
#
# ver 0.1
# 
# This script start/stop replicat ogr replication.
# JDE QA -> OGR  
#
#####################################################################################################################


# Setting up variables
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"
__date=`date +%Y%m`
__time=`date +"%Y-%m-%d %T"`
__work_dir=${__root}/${__date}
__state_file=${__work_dir}/state.file 
__log_file=${__work_dir}/replicat.log
__host=`hostname`

source /home/oracle/ogr001q.env

#mkdir -p  ${__work_dir}

(

_show_error() {
   local message="$1"
   printf "===================================\n"
   printf "\033[31m ${message}. \033[0m\n"
   printf "===================================\n"
}

_check_error() {
   local file_name="$1"
   ERROR_COUNT=0
   ERROR_IMP_COUNT=0
   ERROR_COUNT=`grep "ORA-" ${file_name} |wc -l`
   ERROR_IMP_COUNT=`grep "IMP-" ${file_name} |wc -l`

   if [ "${ERROR_COUNT}" -gt 0 ] || [ "${ERROR_IMP_COUNT}" -gt 0 ]; then
       printf "======================================\n"
       printf "\033[31m Some errors in file ${file_name}\n"
       printf "Please validate.\033[0m\n"
       printf "======================================\n"
       exit 1
   fi
}

if [ "$#" -ne 1 ]; then
   _show_error "You must enter parameter start or stop!!!"
fi 

if [ ${__host} != "slcldv0456m.em3.oraclecloud.com" ]; then
  _show_error "You must run this script on host slcldv0456m!!!"
fi

cd $GG_HOME

printf "GG Home\n"
printf $GG_HOME"\n"


if [ "$1" == "start" ]; then
    printf "Starrting GG replicats...\n"
    $GG_HOME/ggsci << EOF
       info all
       quit
EOF
elif [ "$1" == "stop" ]; then
    printf "Stopping GG replicats...\n"
    $GG_HOME/ggsci << EOF
       info all
       quit
EOF
else
    _show_error "Wrong parameter"
fi




) | tee ${__log_file}











