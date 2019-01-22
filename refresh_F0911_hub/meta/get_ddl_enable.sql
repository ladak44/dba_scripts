set heading off
set linesize 300
set escape off
set echo off

COL echo NOPRINT NEW_VALUE v_echo
COL quit NOPRINT NEW_VALUE v_quit
COL time NOPRINT NEW_VALUE v_time


SELECT 'set timing on' v_time FROM DUAL;
SELECT 'set echo on' v_echo FROM DUAL;


select 'alter table '||owner||'.'||table_name||' enable constraint '||constraint_name||';'  
from dba_constraints 
WHERE  owner = 'QADTA' and constraint_type = 'P'
AND    table_name IN 'F0911';

SELECT 'quit;' v_quit FROM DUAL;


quit;
