#!/usr/bin/env bash


#set -o errexit
set -o nounset
set -o xtrace

############################################################################
#
# refresh_hub.sh 
#
# ver 0.1
# 
# This script refresh HUBBLE QA environment schemas QACTL,QADTA (exluding table QADTA.F0911) from JDE001Q database.
# During refresh period GG replicat process should be stopped. 
# Execution of this script is statefull. 
# Below steps whcih are executed:
# 1.Create DDL script for indexes -> create_idx_hub.sql
# 2.Create DDL script for disable constraints -> disable_constraint.sql
# 3.Create DDL script for enable constraints -> enable_constraint.sql
# 4.Create DDL script to drop inedexes -> drop_indexes.sql
# 5.Disable const
# 6.Drop indexes
# 7.Start imp schema QADTA
# 8.Start imp schema QACTL 
# 9.Create indexes
# 10.Enable constraints
# 11.Gather stats
# 
# You should run this script in nohup mode.
#     
# nohup ./refresh_hub.sh  > refresh_hub.out & 
#
#
##########################################################################

# Setting up variables
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"
__date=`date +%Y%m`
__time=`date +"%Y-%m-%d %T"`
__now=`date +"%Y%m%d%H%M%S"`
__work_dir=${__root}/${__date}
__state_file=${__work_dir}/state.file 
__log_file=${__work_dir}/refresh.log

# DPUMP directorry in hub001q
__db_hub001q_path="/nfsshare/dpump/hub001q/"


source /home/oracle/hub001q.env

mkdir -p  ${__work_dir}

if [ ! -f ${__state_file} ]; then
     touch ${__state_file}
     echo "0" > ${__state_file}
fi

(
printf "======================================\n"
printf "Time: ${__time} \n"
printf "Oracle Home: $ORACLE_HOME \n"
printf "Oracle SID: $ORACLE_SID \n"
printf "Working directory: ${__work_dir} \n"
printf "======================================\n"

_show_message() {
   local file_name="$1"
   echo "===================="
   echo "Some errors in file ${file_name}. Please validate."
   echo "====================" 
}


_check_error() {
   local cmd_status="$?"
   local file_name="$1"
   local step="$2"
   ERROR_COUNT=0
   ERROR_IMP_COUNT=0
   ERROR_COUNT=`grep "ORA-" ${file_name} |wc -l`
   ERROR_IMP_COUNT=`grep "IMP-" ${file_name} |wc -l`

   if [ ${cmd_status} -eq 0 ]; then

           if [ "${ERROR_COUNT}" -gt 0 ] || [ "${ERROR_IMP_COUNT}" -gt 0 ]; then
               printf "======================================\n"
               printf "\033[31m Step: ${step}\n"
               printf " Some errors in file ${file_name}\n"
               printf " Please validate.\033[0m\n"
               printf "======================================\n"
               exit 1
           fi
   else
         printf "======================================\n"
         printf "\033[31m Step: ${step}\n"
         printf " Some problems with command execution.\n"
         printf " Log file: ${file_name} \n"
         printf " Please validate.\033[0m\n"
         printf "======================================\n"
         exit 1
   fi
}



####################################
# Script generation
####################################
# Step 1.
# Create inedexes DDL file - create_idx_hub.sql
if [ `cat ${__state_file}` == '0' ]; then
        __file_output=${__work_dir}/create_idx_hub.sql
        sqlplus -S '/ as sysdba' @${__dir}/get_ddl_idx.sql > ${__file_output}
        _check_error ${__file_output} "1"
        echo "1" > ${__state_file}
        printf "Indexes DDL file created: create_idx_hub.sql\n"
fi

# Step 2.
# Disable const script - disable_constraint.sql
if [ `cat ${__state_file}` == '1' ]; then
        __file_output=${__work_dir}/disable_constraint.sql
        sqlplus -S '/ as sysdba' @${__dir}/get_ddl_disable.sql > ${__file_output}
        _check_error ${__file_output} "2"
        echo "2" > ${__state_file}
        printf "Disable constraints DDL file created: disable_constraint.sql\n"
fi

# Step 3.
# Enable const script - enable_constraint.sql
if [ `cat ${__state_file}` == '2' ]; then
        __file_output=${__work_dir}/enable_constraint.sql
        sqlplus -S '/ as sysdba' @${__dir}/get_ddl_enable.sql > ${__file_output}
        _check_error ${__file_output} "3"
        echo "3" > ${__state_file}
        printf "Enable constraints DDL file created: disable_constraint.sql\n"
fi

# Step 4.
# Drop indexes DDL script drop_idx.sql
if [ `cat ${__state_file}` == '3' ]; then
        __file_output=${__work_dir}/drop_idx.sql
        sqlplus -S '/ as sysdba' @${__dir}/get_ddl_drop_idx.sql > ${__file_output}
        _check_error ${__file_output} "4"
        echo "4" > ${__state_file}
        printf "Drop indexes DDL file created: drop_idx.sql \n"
fi




# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
exit 1

####################################
# Script executions
####################################


# Step 5.
# Disable constriant
if [ `cat ${__state_file}` == '4' ]; then
        __file_output=${__work_dir}/disable_constraint.log
        #sqlplus '/ as sysdba' @${__work_dir}/disable_constraint.sql > ${__file_output}
        _check_error ${__file_output} "5"
        echo "5" > ${__state_file}
        printf "Constraints disabled \n"
fi

# Step 6.
# Drop indexes
if [ `cat ${__state_file}` == '5' ]; then
        __file_output=${__work_dir}/drop_indexes.log
        #sqlplus '/ as sysdba' @${__work_dir}/drop_idx.sql > ${__file_output}
        _check_error ${__file_output} "6"
        echo "6" > ${__state_file}
        printf "Indexes dropped \n"
fi

# Step 7.
# Import QADTA schema except F0911 table.
if [ `cat ${__state_file}` == '6' ]; then
        __file_output=${__db_hub001q_path}/imp_qadta.log
        if [ -e ${__file_output} ]; then
             rm -f ${__file_output}
        fi
        #impdp \'/ as sysdba\' network_link=JDE001Q schemas=QADTA exclude=TABLE:"= 'F0911'"  TABLE_EXISTS_ACTION=truncate exclude=PROCACT_INSTANCE,constraint,index,statistics  directory=DPUMP cluster=n logfile=imp_qadta.log
        _check_error ${__file_output} "7"
        echo "7" > ${__state_file}
        printf "Rest tables imported \n"
fi

# Step 8.
# Import QACTL schema 
if [ `cat ${__state_file}` == '7' ]; then
        __file_output=${__db_hub001q_path}/imp_qactl.log
        if [ -e ${__file_output} ]; then
             rm -f ${__file_output}
        fi
        #impdp \'/ as sysdba\' network_link=JDE001Q schemas=QACTL TABLE_EXISTS_ACTION=truncate exclude=PROCACT_INSTANCE,constraint,index,statistics  directory=DPUMP cluster=n logfile=imp_qactl.log
        _check_error ${__file_output} "8"
        echo "8" > ${__state_file}
        printf "Rest tables imported \n"
fi


# Step 9.
# Create indexes
if [ `cat ${__state_file}` == '8' ]; then
        __file_output=${__work_dir}/create_idx_hub.log
        #sqlplus '/ as sysdba' @${__dir}/create_idx_hub.sql > ${__file_output}
        _check_error ${__file_output} "9"
        echo "9" > ${__state_file}
        printf "Indexes created \n"
fi


#Step 10.
#Enable constraint
if [ `cat ${__state_file}` == '9' ]; then
        __file_output=${__work_dir}/enable_constraint.log
        #sqlplus '/ as sysdba' @${__dir}/enable_constraint.sql >> ${__file_output}
        _check_error ${__file_output} "10"
        echo "10" > ${__state_file}
        printf "Constraints enabled \n"
fi

#Step 11.
#Gather schema stats.
if [ `cat ${__state_file}` == '10' ]; then
	__file_output=${__work_dir}/gather_schema_stats.log
	#sqlplus '/ as sysdba' @${__work_dir}/gather_stats.sql > ${__file_output} 
	_check_error ${__file_output} "11"
	echo "11" > ${__state_file}
        printf "Statistics gathered on schemas QADTA and QACTL. \n"
fi



printf "==========================================================\n"
printf "Time:" ${__time}
printf "\033[32m SUCCESS: All steps finished successfully. \033[0m\n"
printf "==========================================================\n"


) | tee ${__log_file}











