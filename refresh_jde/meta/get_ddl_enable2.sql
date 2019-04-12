-- -----------------------------------------------------------------------------------
-- File Name    : get_ddl_enable2.sql  
-- Author       : marclad
-- Description  : Displays the DDL constraint to be enable for a specific user.
-- Call Syntax  : @get_ddl_enable2.sql (usernames)
-- Last Modified: 13/04/2019
-- -----------------------------------------------------------------------------------

set heading off
set linesize 300
set escape off
set echo off

COL parallel NOPRINT NEW_VALUE v_parallel
COL echo NOPRINT NEW_VALUE v_echo
COL quit NOPRINT NEW_VALUE v_quit
COL time NOPRINT NEW_VALUE v_time


variable v_username VARCHAR2(30);

exec :v_username := '&1';


SELECT 'alter session force parallel ddl parallel &2;' v_parallel FROM DUAL;
SELECT 'set echo on' v_echo FROM DUAL;
SELECT 'set timing on' v_time FROM DUAL;


select 'alter table '||owner||'.'||table_name||' enable constraint '||constraint_name||';'  
from dba_constraints 
WHERE constraint_type IN ('U', 'P','R') and owner in (select regexp_substr(:v_username,'[^,]+', 1, level)
   from dual
    connect by
        regexp_substr(:v_username, '[^,]+', 1, level)
            is not null) ;

SELECT 'quit;' v_quit FROM DUAL;

quit;
