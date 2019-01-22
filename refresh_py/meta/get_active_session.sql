set heading off
set escape off

COL echo NOPRINT NEW_VALUE v_echo
COL quit NOPRINT NEW_VALUE v_quit
COL time NOPRINT NEW_VALUE v_time


SELECT 'set echo on' v_echo FROM DUAL;


select 'ALTER SYSTEM DISCONNECT SESSION '''||a.sid||','||a.serial#||''' IMMEDIATE;' 
from v$session a where a.username in ('CRPDTA','CRPCTL');

SELECT 'quit;' v_quit FROM DUAL;

quit;
