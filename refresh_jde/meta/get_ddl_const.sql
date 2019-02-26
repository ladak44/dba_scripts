-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/user_ddl.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for a specific user.
-- Call Syntax  : @user_ddl (username)
-- Last Modified: 07/08/2018
-- -----------------------------------------------------------------------------------

set heading off
set echo off

COL parallel NOPRINT NEW_VALUE v_parallel
COL quit NOPRINT NEW_VALUE v_quit
COL echo NOPRINT NEW_VALUE v_echo
COL time NOPRINT NEW_VALUE v_time

SELECT 'set echo on' v_echo FROM DUAL;
SELECT 'set timing on' v_time FROM DUAL;

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/table_constraints_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the UK & PK constraint DDL for specified table, or all tables.
-- Call Syntax  : @table_constraints_ddl (schema-name) (table-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'STORAGE', false);
END;
/

SELECT 'alter session force parallel ddl parallel &2;' v_parallel FROM DUAL;

SELECT DBMS_METADATA.get_ddl ('CONSTRAINT', constraint_name, owner)
FROM   dba_constraints
WHERE  owner      = UPPER('&1');


SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON


set linesize 80 pagesize 14 feedback on trimspool on verify on

SELECT 'quit;' v_quit FROM DUAL;


quit;
