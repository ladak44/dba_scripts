#!/usr/bin/env bash


#set -o errexit
set -o nounset
set -o xtrace

####################################################################################################
#
#  refresh_py.sh
#
#  ver 0.1
# 
# This script refresh PY environment (schemas CRPDTA,CRPCTL) on database jde001d with data from jde001q.
# Execution of this script is statefull. 
# Below steps whcih are executed:
# 1.Create DDL script for user's CRPDTA CRPCTL ->  create_users_py.sql
# 2.Create DDL script for indexes ->  create_idx_py.sql
# 3.Export metadata 
# 4.Export tables CRPCTL 
# 5.Export tables CRPDTA  
# 5.Drop users
# 6.Create users 
# 7.Start imp jde001q database
# 8.Create indexes
# 9.Enable constraints 
# 10.Import tables 
# 11.Gather stats
#
# You can launch this script in nohup mode.
# 
# nohup ./refresh_py.sh  > refresh_py.out &
#  
###################################################################################################

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

# DB directory in jde001d
__db_jde001d_path="/nfsshare/dpump/jde001d/"


source /home/oracle/jde001d.env

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
# Create users DDL file - create_users_py.sql
if [ `cat ${__state_file}` == '0' ]; then
	__file_output=${__work_dir}/create_users_py.sql
	sqlplus -S '/ as sysdba' @${__dir}/get_ddl_users_CRPDTA_CRPCTL.sql > ${__file_output}
	_check_error ${__file_output} "1"
	echo "1" > ${__state_file}
        printf "Users DDL file created: create_users_py.sql\n"
fi 

# Step 2.
# Create indexes DDL file -  
if [ `cat ${__state_file}` == '1' ]; then
	__file_output=${__work_dir}/create_idx_py.sql
	sqlplus -S '/ as sysdba' @${__dir}/get_ddl_idx.sql > ${__file_output}
	_check_error ${__file_output} "2"
	echo "2" > ${__state_file}
        printf "Indexes DDL file created: create_idx_py.sql\n"
fi 

# Step 3.
# Export metadata
if [ `cat ${__state_file}` == '2' ]; then
        __file_output=${__db_jde001d_path}/meta_refresh_exp.log
        __file_dump=${__db_jde001d_path}/meta_refresh.dmp
        if [ -e ${__file_output} ]; then
                rm -f ${__file_output}
        fi
        if [ -e ${__file_dump} ]; then
                rm -f ${__file_dump}
        fi
        expdp \'/ as sysdba\' directory=DPUMP schemas=CRPDTA,CRPCTL CONTENT=METADATA_ONLY dumpfile=meta_refresh.dmp logfile=meta_refresh_exp.log
        _check_error ${__file_output} "3"
        echo "3" > ${__state_file}
        printf "Meta data was exported.\n"
fi

# Step 4.
# Export tables CRPCTL schema
if [ `cat ${__state_file}` == '3' ]; then
	__file_output=${__db_jde001d_path}/crpctl_tables_exp.log
        __file_dump=${__db_jde001d_path}/crpctl_tables.dmp
        if [ -e ${__file_output} ]; then
                rm -f ${__file_output}
        fi
        if [ -e ${__file_dump} ]; then
                rm -f ${__file_dump}
        fi
        expdp \'/ as sysdba\' parfile=${__dir}/crpctl_tables.prm 
	_check_error ${__file_output} "4"
	echo "4" > ${__state_file}
        printf "Export tables schema CRPCTL \n"
fi


# Step 5.
# Export tables CRPDTA schema
if [ `cat ${__state_file}` == '4' ]; then
	__file_output=${__db_jde001d_path}/crpdta_tables_exp.log
        __file_dump=${__db_jde001d_path}/crpdta_tables.dmp
        if [ -e ${__file_output} ]; then
                rm -f ${__file_output}
        fi
        if [ -e ${__file_dump} ]; then
                rm -f ${__file_dump}
        fi
        expdp \'/ as sysdba\' parfile=${__dir}/crpdta_tables.prm 
	_check_error ${__file_output} "5"
	echo "5" > ${__state_file}
        printf "Export tables schema CRPDTA \n"
fi

## <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
exit 1
## <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

####################################
# Script executions
####################################

# Step 6.
# Drop users CRPDTA and CRPCTL
if [ `cat ${__state_file}` == '5' ]; then
       # check if any active sessions exists  
       __file_output=${__work_dir}/kill_active_session.sql
       sqlplus '/ as sysdba' @${__dir}/get_active_session.sql > ${__file_output} 
       _check_error ${__file_output} "6"
       # kill all sessions connected to users  
#       sqlplus '/ as sysdba' @${__dir}/kill_active_session.sql > ${__file_output} 
       _check_error ${__file_output} "6"
       __file_output=${__work_dir}/drop_users.log
#       sqlplus '/ as sysdba' @${__dir}/drop_users.sql > ${__file_output} 
	_check_error ${__file_output} "6"
	echo "5" > ${__state_file}
        printf "Users CRPDTA and CRPCTL dropped. \n"
fi

# Step 7.
# Create users 
if [ `cat ${__state_file}` == '6' ]; then
	__file_output=${__work_dir}/create_users.log
	#sqlplus '/ as sysdba' @${__work_dir}/create_users_py.sql > ${__file_output} 
	_check_error ${__file_output} "7"
	echo "7" > ${__state_file}
        printf "Users CRPDTA and CRPCTL created. \n"
fi

# Step 8.
# Import data from jde001q 
if [ `cat ${__state_file}` == '7' ]; then
        __file_output=${__db_jde001d_path}/refresh_py.log
        if [ -e ${__file_output} ]; then
                rm -f ${__file_output}
        fi
#        impdp \'/ as sysdba\' directory=dpump network_link=JDEDEVQ.STATOILFUELRETAIL.COM schemas=('QADTA','QACTL') remap_schemas=QADTA:CRPDTA,QACTL:CRPCTL exclude=indexes,statistics \
                transform=disable_archive_logging:y  transform=table_compression_clause:\"COLUMN STORE COMPRESS FOR QUERY HIGH\"  logfile=refresh_py.log parallel=8 
	_check_error ${__file_output} "8"
	echo "8" > ${__state_file}
        printf "Import data from jde001q finished. \n"
fi


# Step 9.
# Import metadata 
if [ `cat ${__state_file}` == '8' ]; then
	__file_output=${__work_dir}/meta_refresh_imp.log
	__file_dump=${__db_jde001d_path}/meta_refresh.dmp
        if [ -e ${__file_output} ]; then
                rm -f ${__file_output}
        fi
        if [ -e ${__file_dump} ]; then
                rm -f ${__file_dump}
        fi
        impdp '/ as sysdba\' directory=DPUMP schemas=CRPDTA,CRPCTL CONTENT=METADATA_ONLY dumpfile=meta_refresh.dmp logfile=meta_refresh_imp.log         
	_check_error ${__file_output} "9"
	echo "9" > ${__state_file}
        printf "Import of metadata is finished. \n"
fi


#Step 10.
#Import tables schema CRPCTL
if [ `cat ${__state_file}` == '9' ]; then
	__file_output=${__work_dir}/crpctl_tables_imp.log
	__file_dump=${__db_jde001d_path}/crpctl_tables.dmp
        if [ -e ${__file_output} ]; then
                rm -f ${__file_output}
        fi
        if [ -e ${__file_dump} ]; then
                rm -f ${__file_dump}
        fi
        impdp \'/ as sysdba\' schemas=CRPCTL parallel=8 directory=DPUMP dumpfile=crpctl_tables.dmp logfile=crpctl_tables_imp.log transform=table_compression_clause:\"COLUMN STORE COMPRESS FOR QUERY HIGH\"
	_check_error ${__file_output} "10"
	echo "10" > ${__state_file}
        printf "Import of tables from schema CRPCTL is finished. \n"
fi

#Step 11.
#Import tables schema CRPDTA
if [ `cat ${__state_file}` == '10' ]; then
	__file_output=${__work_dir}/crpdta_tables_imp.log
	__file_dump=${__db_jde001d_path}/crpdta_tables.dmp
        if [ -e ${__file_output} ]; then
                rm -f ${__file_output}
        fi
        if [ -e ${__file_dump} ]; then
                rm -f ${__file_dump}
        fi
        impdp \'/ as sysdba\' schemas=CRPDTA parallel=8 directory=DPUMP dumpfile=crpdta_tables.dmp logfile=crpdta_tables_imp.log transform=table_compression_clause:\"COLUMN STORE COMPRESS FOR QUERY HIGH\"
	_check_error ${__file_output} "11"
	echo "11" > ${__state_file}
        printf "Import of tables from schema CRPDTA is finished. \n"
fi

#Step 12.
#Gather schema stats.
if [ `cat ${__state_file}` == '10' ]; then
	__file_output=${__work_dir}/gather_schema_stats.log
	#sqlplus '/ as sysdba' @${__work_dir}/gather_stats.sql > ${__file_output} 
	_check_error ${__file_output} "12"
	echo "12" > ${__state_file}
        printf "Statistics gathered on schemas CRPDTA and CRPCTL. \n"
fi



printf "==========================================================\n"
printf "Time:" ${__time}
printf "\033[32m SUCCESS: All steps finished successfully. \033[0m\n"
printf "==========================================================\n"


) | tee ${__log_file}











