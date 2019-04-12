-- -----------------------------------------------------------------------------------
-- File Name    : get_active_session2.sql  
-- Author       : marclad
-- Description  : Displays the DDL to kill active session for a specific users.
-- Call Syntax  : @get_active_session2.sql (usernames)
-- Last Modified: 13/04/2019
-- -----------------------------------------------------------------------------------


set heading off
set escape off

COL echo NOPRINT NEW_VALUE v_echo
COL quit NOPRINT NEW_VALUE v_quit
COL time NOPRINT NEW_VALUE v_time


variable v_username VARCHAR2(30);

exec :v_username := '&1';


SELECT 'set echo on' v_echo FROM DUAL;


select 'ALTER SYSTEM DISCONNECT SESSION '''||a.sid||','||a.serial#||''' IMMEDIATE;' 
from v$session a where a.username in (select regexp_substr(:v_username,'[^,]+', 1, level)
   from dual
    connect by
        regexp_substr(:v_username, '[^,]+', 1, level)
            is not null);

SELECT 'quit;' v_quit FROM DUAL;

quit;
