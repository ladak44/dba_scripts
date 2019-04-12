-- -----------------------------------------------------------------------------------
-- File Name    : get_ddl_user_privs.sql 
-- Author       : marclad
-- Description  : Displays the DDL privilages from dba_tab_privs for a specific users.
-- Last Modified: 07/08/2018
-- -----------------------------------------------------------------------------------

set heading off

COL quit NOPRINT NEW_VALUE v_quit
COL echo NOPRINT NEW_VALUE v_echo
COL time NOPRINT NEW_VALUE v_time

SELECT 'set echo on' v_echo FROM DUAL;
SELECT 'set timing on' v_time FROM DUAL;


set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000

begin
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true);
end;
/

variable v_username VARCHAR2(30);

exec :v_username := '&1';

select 'GRANT '||a.privilege||' ON '||a.owner||'.'||a.table_name||' TO '||a.grantee||';'  
from dba_tab_privs a
where a.owner in
(select regexp_substr(:v_username,'[^,]+', 1, level) 
   from dual 
    connect by 
        regexp_substr(:v_username, '[^,]+', 1, level) 
            is not null)
/


set linesize 80 pagesize 14 feedback on trimspool on verify on

SELECT 'quit;' v_quit FROM DUAL;

quit;
