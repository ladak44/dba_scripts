-- -----------------------------------------------------------------------------------
-- File Name    : get_ddl_user_drop.sql  
-- Author       : marclad
-- Description  : Displays the DDL command to user drops for a specific user.
-- Call Syntax  : @get_ddl_user_drop.sql (usernames)
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

variable v_username VARCHAR2(30);

exec :v_username := '&1';

select 'drop user '||username||' cascade;'
from dba_users
where username in  
(select regexp_substr(:v_username,'[^,]+', 1, level)
   from dual
    connect by
        regexp_substr(:v_username, '[^,]+', 1, level)
            is not null);


SELECT 'quit;' v_quit FROM DUAL;


quit;
