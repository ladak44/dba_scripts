-- -----------------------------------------------------------------------------------
-- File Name    : get_ddl_idx2.sql 
-- Author       : marclad
-- Description  : Displays the DDL indexes for a specific users.
-- Last Modified: 12/04/2019
-- -----------------------------------------------------------------------------------

set heading off
set escape off


COL parallel NOPRINT NEW_VALUE v_parallel 
COL quit NOPRINT NEW_VALUE v_quit
COL echo NOPRINT NEW_VALUE v_echo
COL time NOPRINT NEW_VALUE v_time


SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
   -- Uncomment the following lines if you need them.
   --DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SEGMENT_ATTRIBUTES', false);
   --DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'STORAGE', false);
END;
/


variable v_username VARCHAR2(30);

exec :v_username := '&1';


SELECT 'alter session force parallel ddl parallel &2;' v_parallel FROM DUAL;
SELECT 'set echo on' v_echo FROM DUAL;
SELECT 'set timing on' v_time FROM DUAL;


SELECT DBMS_METADATA.get_ddl ('INDEX', index_name, owner)
FROM   dba_indexes
WHERE  owner     in (select regexp_substr(:v_username,'[^,]+', 1, level)
   from dual
    connect by
        regexp_substr(:v_username, '[^,]+', 1, level)
            is not null); 


SELECT 'quit;' v_quit FROM DUAL;

quit;
