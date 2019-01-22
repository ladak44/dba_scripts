
set heading off


COL quit NOPRINT NEW_VALUE v_quit
COL echo NOPRINT NEW_VALUE v_echo
COL time NOPRINT NEW_VALUE v_time

SELECT 'set echo on' v_echo FROM DUAL;
SELECT 'set timing on' v_time FROM DUAL;


SELECT 'drop index '||owner||'.'||index_name ||';'
FROM   dba_indexes
WHERE  owner in ('QADTA','QACTL') and table_name <> 'F0911' ;

SELECT 'quit;' v_quit FROM DUAL;

quit;
