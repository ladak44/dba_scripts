set heading off
set linesize 300
set escape off
set echo off

COL quit NOPRINT NEW_VALUE v_quit
COL echo NOPRINT NEW_VALUE v_echo
COL time NOPRINT NEW_VALUE v_time


SELECT 'set echo on' v_echo FROM DUAL;
SELECT 'set timing on' v_time FROM DUAL;


select 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||';'  
from dba_constraints 
WHERE  owner = 'QADTA' and constraint_type = 'P'
AND    table_name = 'F0911';

SELECT 'quit;' v_quit FROM DUAL;



quit;
