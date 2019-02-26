set heading off
set linesize 300
set escape off
set echo off

COL parallel NOPRINT NEW_VALUE v_parallel
COL echo NOPRINT NEW_VALUE v_echo
COL quit NOPRINT NEW_VALUE v_quit
COL time NOPRINT NEW_VALUE v_time

SELECT 'alter session force parallel ddl parallel &2;' v_parallel FROM DUAL;
SELECT 'set echo on' v_echo FROM DUAL;
SELECT 'set timing on' v_time FROM DUAL;


select 'alter table '||owner||'.'||table_name||' enable constraint '||constraint_name||';'  
from dba_constraints 
WHERE  owner = UPPER('&1');

SELECT 'quit;' v_quit FROM DUAL;

quit;
