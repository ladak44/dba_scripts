#!/usr/bin/env bash


#set -o errexit
set -o nounset
set -o xtrace

# This script refresh JDE 9.2 database environment, import schema using database link.
# Execution of this script is stateful.
# It should be launched on target site.
# System password is needed to create temporary db link on target site.
# There is authentication via wallet so users sys should be added to it.  
# I assume the pump directory is located under /nfsshare/dpump/ and
# aprioprate foleders will be created there.
# 
# Below steps whcih are executed:
# 1.Create DDL script for user ->  create_users.sql
# 2.Create DDL script for indexes ->  create_idx.sql
# 3.Create DDL script for constraints -> create_constraints.sql
# 4.Create DDL script to enable constraints -> enable_constraintssql 
# 5.Drop user on target
# 6.Create dblink on target
# 7.Create directory on target
# 8.Import schema
# 9.Create indexes
# 10.Create constraints
# 11.Enable constraints 
# 12.Gather stats
# 13.Drop database link on target
#
# Usage:
# 
# @1 - file with parameters 
# @2 - password for system user
# 
# eg:
# refresh2.sh jde92.prm ********** 
#  

# Fix
# add system password as parameter
# add parser for parameter file
# add possibility to process multiple schemas simultaneously


# Setting up variables
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"
__date=`date +%Y%m`
__time=`date +"%Y-%m-%d %T"`
__work_dir=${__root}/${__date}
__state_file=${__work_dir}/state.file 
__log_file=${__work_dir}/refresh.log
__source_sid=''
__target_sid=''
__schema=''
__system_password=''
__pump_directory="/nfsshare/dpump"

_show_message() {
   local message="$1"
   echo "===================="
   echo "${message}"
   echo "====================" 
}

_show_error() {
     local message="$1" 
     printf "======================================\n"
     printf "\033[31m ${message} \033[0m \n"
     printf "======================================\n"
     exit 1
}

_check_error() {
   local file_name="$1"
   ERROR_COUNT=0
   ERROR_COUNT=`grep "ORA-" ${file_name} | wc -l`
   ERROR_IMP_COUNT=`grep "IMP-" ${file_name} | wc -l` 
   FILE_SIZE=`wc -c ${file_name} | awk '{print $1}'`

   if [ "${FILE_SIZE}" = 0 ]; then
       printf "======================================\n"
       printf "\033[31mFile ${file_name} has 0KB\n"
       printf "Please validate.\033[0m\n"
       printf "======================================\n"
       exit 1
   fi
   
   if [ "${ERROR_COUNT}" -gt 0 ] || [ "${ERROR_IMP_COUNT}" -gt 0 ]; then
       printf "======================================\n"
       printf "\033[31mSome errors in file ${file_name}\n"
       printf "Please validate.\033[0m\n"
       printf "======================================\n"
       exit 1
   fi
}

_check_db_connection() {
   local sid="$1"
   sqlplus -S /@${sid} as sysdba << EOF
       set heading off
       select 'Connected to database: '||name from v\$database; 
     quit;
EOF

 if [ "$?" -gt 0 ]; then   
  _show_error "Problem with connection to database: ${sid}"
 fi 
}

# check number of input parameters
if [ "$#" -ne 2 ]; then
  _show_error "Wrong number of input parameters..."
fi 

# check if file parameter exist
if [ ! -f $1 ]; then
  _show_error "File "$1" dosen't exist.."
fi 

# assign input parameters
__parameter_file=$1
__system_password=$2

# get parameter value
get_parameter() { 
    local l_param=$1
    while read line; do  
      # skip comment line  
      if  [[ $line != \#* ]]; then
         param=$(echo $line | cut -d '=' -f1)
         value=$(echo $line | cut -d '=' -f2)
         if [ ${l_param} == ${param} ]; then 
            echo ${value}
         fi      
       fi
    done < ${__parameter_file}
}

__source_sid=`get_parameter "source_sid"`
__target_sid=`get_parameter "target_sid"`
__source_schema=`get_parameter "source_schema"`
__target_schema=`get_parameter "target_schema"`
__source_idx_tbs=`get_parameter "source_idx_tbs"`
__target_idx_tbs=`get_parameter "target_idx_tbs"`
__source_dta_tbs=`get_parameter "source_dta_tbs"`
__target_dta_tbs=`get_parameter "target_dta_tbs"`
__parallelism=`get_parameter "parallelism"`
__drop_user=`get_parameter "drop_user"`

__work_dir=${__root}/${__date}/${__target_schema}
__state_file=${__work_dir}/state.file
__log_file=${__work_dir}/refresh.log
__db_link_name="IMPDP_"${__target_schema}
__directory_name="DIR_"${__target_schema}
__pump_directory=${__pump_directory}/${__target_sid}/${__date}/${__target_schema}

# create working directory
mkdir -p  ${__work_dir}
# create state file
if [ ! -f ${__state_file} ]; then
     touch ${__state_file}
     echo "0" > ${__state_file}
fi

# create directory for pump
if [ ! -d ${__pump_directory} ]; then
   mkdir -p ${__pump_directory} 
fi 


(
printf "======================================\n"
printf "Time: ${__time} \n"
printf "Parameter file: ${__parameter_file} \n"
printf "Source SID: ${__source_sid} \n"
printf "Target SID: ${__target_sid} \n"
printf "Source Schema: ${__source_schema} \n"
printf "Target Schema: ${__target_schema} \n"
printf "Source IDX tablespace: ${__source_idx_tbs} \n"
printf "Target IDX tablespace: ${__target_idx_tbs} \n"
printf "Source DTA tablespace: ${__source_dta_tbs} \n"
printf "Target DTA tablespace: ${__target_dta_tbs} \n"
printf "Working directory: ${__work_dir} \n"
printf "Database link: ${__db_link_name} \n"
printf "Directory name: ${__directory_name} \n"
printf "Parallelism: ${__parallelism} \n"
printf "Drop user: ${__drop_users} \n"
printf "======================================\n"

# set up envrionment -  source
source /home/oracle/"${__source_sid}".env

####################################
# Script generation for target user
####################################

# Step 1.
# Create users DDL file - create_user_privs.sql 
if [ `cat ${__state_file}` == '0' ]; then
        __file_output=${__work_dir}/create_user_privs.sql
        sqlplus -S /@${__source_sid} as sysdba @${__dir}/get_ddl_user_privs.sql ${__source_schema} > ${__file_output}
        _check_error ${__file_output}
        echo "1" > ${__state_file}
        printf "Users privileges DDL file created: create_user.sql\n"
        # replace schema name
	sed -i -e s/"${__source_schema}"/"${__target_schema}"/g ${__file_output}
	# replace tablespace name
	sed -i -e s/"${__source_idx_tbs}"/"${__target_idx_tbs}"/g ${__file_output}      
fi


# Step 2.
# Create indexes DDL script create_idx.sql
# Replace tablespace name 
if [ `cat ${__state_file}` == '1' ]; then
	__file_output=${__work_dir}/create_idx.sql
	sqlplus -S /@${__source_sid}  as sysdba @${__dir}/get_ddl_idx2.sql ${__source_schema} ${__parallelism} > ${__file_output}
	_check_error ${__file_output}
	echo "2" > ${__state_file}
        printf "Indexes DDL file created: create_idx.sql \n"
        # replace schema name
	sed -i -e s/"${__source_schema}"/"${__target_schema}"/g ${__file_output}
	# replace tablespace name
	sed -i -e s/"${__source_idx_tbs}"/"${__target_idx_tbs}"/g ${__file_output}       
fi

# Step 3.
# Create constraints DDL script create_constraints.sql
if [ `cat ${__state_file}` == '2' ]; then
	__file_output=${__work_dir}/create_constraints.sql
	sqlplus -S /@${__source_sid} as sysdba @${__dir}/get_ddl_const2.sql ${__source_schema} ${__parallelism} > ${__file_output}
	_check_error ${__file_output}
        # replace schema name
	sed -i -e s/"${__source_schema}"/"${__target_schema}"/g ${__file_output}
        # replace ENABLE -> DISABLE
        sed -i -e s/"ENABLE"/"DISABLE"/g ${__file_output}
	echo "3" > ${__state_file}
        printf "Constraints DDL file created: create_constraints.sql \n"
fi

# Step 4.
# Enable constraints DDL script enable_constraints.sql
if [ `cat ${__state_file}` == '3' ]; then
        __file_output=${__work_dir}/enable_constraints.sql
        sqlplus -S /@${__source_sid} as sysdba @${__dir}/get_ddl_enable2.sql ${__source_schema} ${__parallelism} > ${__file_output}
        _check_error ${__file_output} 
	sed -i -e s/"${__source_schema}"/"${__target_schema}"/g ${__file_output}
        echo "4" > ${__state_file}
        printf "Enable constraints DDL file created: enable_constraints.sql\n"
fi



set up envrionment
source /home/oracle/"${__target_sid}".env
####################################
# Script executions
####################################

# Step 5.
# Drop user on target
if [ `cat ${__state_file}` == '4' ]; then
       # check if any active sessions exists  
       __file_output=${__work_dir}/kill_active_session.sql
       sqlplus -S /@${__target_sid} as sysdba @${__dir}/get_active_session2.sql ${__target_sid} > ${__file_output}
       # kill all sessions connected to users
       __file_output=${__work_dir}/kill_active_session.log  
       sqlplus -S /@${__target_sid} as sysdba @${__work_dir}/kill_active_session.sql > ${__file_output} 
       __file_output=${__work_dir}/drop_users.log
       sqlplus -S /@${__target_sid} as sysdba @${__dir}/drop_users.sql ${__target_schema} > ${__file_output} 
       _check_error ${__file_output} 
       echo "5" > ${__state_file}
       printf "User ${__target_schema}  dropped. \n"
fi


# Step 6.
# Create db_link on target
if [ `cat ${__state_file}` == '5' ]; then
	__file_output=${__work_dir}/db_link.log
        __sql_text="CREATE DATABASE LINK ${__db_link_name} CONNECT TO system IDENTIFIED BY ${__system_password} USING '${__source_sid}';"
# create as system user
        sqlplus system/${__system_password} @${__target_sid} << EOF > ${__file_output}
${__sql_text}
select * from dual@${__db_link_name};
EOF
	_check_error ${__file_output}
	echo "6" > ${__state_file}
        printf "Db link created. \n"
fi


# Step 7.
# Create directory.
if [ `cat ${__state_file}` == '5' ]; then
	__file_output=${__work_dir}/db_directory.log
        __sql_text="CREATE DIRECTORY ${__directory_name} as '${__pump_directory}';"
        sqlplus -S /@${__target_sid} as sysdba << EOF > ${__file_output}
${__sql_text}
EOF
	_check_error ${__file_output}
	echo "7" > ${__state_file}
        printf "Directory created. \n"
fi


# Step 8.
# Import schema
# Fix
# error handling has to be done
if [ `cat ${__state_file}` == '7' ]; then
	__file_output=${__pump_directory}/imp_data.log
	impdp \'system/${__system_password}@${__target_sid}\' schemas=${__source_schema} remap_schema=${__source_schema}:${__target_schema} remap_tablespace=${__source_dta_tbs}:${__target_dta_tbs},${__source_idx_tbs}:${__target_idx_tbs} network_link=${__db_link_name} exclude=constraint,index,statistics  directory=${__directory_name}  cluster=n logfile=imp_data.log parallel=${__parallelism}  
	_check_error ${__file_output}
	echo "8" > ${__state_file}
        printf "Schema imported \n"
fi


# Step 9.
# Create indexes
if [ `cat ${__state_file}` == '8' ]; then
	__file_output=${__work_dir}/create_idx.log
        sqlplus /@${__target_sid} as sysdba @${__work_dir}/create_idx.sql > ${__file_output}
	_check_error ${__file_output}
	echo "9" > ${__state_file}
        printf "Indexes created \n"
fi


#Step 10.
#Create constraint
if [ `cat ${__state_file}` == '9' ]; then
	__file_output=${__work_dir}/create_constraints.log
	sqlplus /@${__target_sid} as sysdba @${__work_dir}/create_constraints.sql > ${__file_output}
	_check_error ${__file_output}
	echo "10" > ${__state_file}
        printf "Constraints created \n"
fi

#Step 11.
#Enable constraints
if [ `cat ${__state_file}` == '10' ]; then
        __file_output=${__work_dir}/enable_constraints.log
        sqlplus /@${__target_sid} as sysdba @${__work_dir}/enable_constraints.sql > ${__file_output}
        _check_error ${__file_output}
        echo "11" > ${__state_file}
        printf "Constraints enabled \n"
fi


#Step 12.
#Gather stats
if [ `cat ${__state_file}` == '11' ]; then
	__file_output=${__work_dir}/gather_stats.log
        __sql_text="exec dbms_stats.gather_schema_stats (ownname=>'${__target_schema}',granularity =>'GLOBAL',CASCADE=> true,estimate_percent=>dbms_stats.auto_sample_size,degree=>dbms_stats.auto_degree);"
	sqlplus -S /@${__target_sid} as sysdba  << EOF > ${__file_output}
${__sql_text}
EOF
	_check_error ${__file_output}
	echo "12" > ${__state_file}
        printf "Statistics gathered \n"
fi


# 12.
# Drop database link
if [ `cat ${__state_file}` == '11' ]; then
	__file_output=${__work_dir}/drop_db_link.log
        __sql_text="DROP DATABASE LINK ${__db_link_name};"
        sqlplus system/${__system_password} @${__target_sid} << EOF > ${__file_output}
${__sql_text}
EOF
	_check_error ${__file_output}
	echo "12" > ${__state_file}
        printf "Db link dropped. \n"
fi

# 13.
# Drop directory 
if [ `cat ${__state_file}` == '12' ]; then
	__file_output=${__work_dir}/drop_directory.log
        __sql_text="DROP DIRECTORY ${__directory_name};"
        sqlplus -S /@${__target_sid} as sysdba << EOF > ${__file_output}
${__sql_text}
EOF
	_check_error ${__file_output}
	echo "13" > ${__state_file}
        printf "Directory dropped. \n"
fi



printf "==========================================================\n"
printf "Time:" ${__time}
printf "\033[32m SUCCESS: All steps finished successfully. \033[0m\n"
printf "==========================================================\n"


) | tee ${__log_file}











