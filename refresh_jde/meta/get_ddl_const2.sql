-- -----------------------------------------------------------------------------------
-- File Name    : get_ddl_const2.sql  
-- Author       : marclad
-- Description  : Displays the DDL constraint for a specific user.
-- Call Syntax  : @get_ddl_const2.sql (usernames)
-- Last Modified: 13/04/2019
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

variable v_username VARCHAR2(30);

exec :v_username := '&1';


SELECT 'alter session force parallel ddl parallel &2;' v_parallel FROM DUAL;

SELECT DBMS_METADATA.get_ddl ('CONSTRAINT', constraint_name, owner)
FROM   dba_constraints
WHERE   constraint_type IN ('U', 'P') and  owner in (select regexp_substr(:v_username,'[^,]+', 1, level)
   from dual
    connect by
        regexp_substr(:v_username, '[^,]+', 1, level)
            is not null);

SELECT DBMS_METADATA.get_ddl ('REF_CONSTRAINT', constraint_name, owner)
FROM   dba_constraints
WHERE   constraint_type = 'R' and  owner in (select regexp_substr(:v_username,'[^,]+', 1, level)
   from dual
    connect by
        regexp_substr(:v_username, '[^,]+', 1, level)
            is not null);


SELECT 'quit;' v_quit FROM DUAL;


quit;
