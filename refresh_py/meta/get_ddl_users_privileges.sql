
select 'GRANT '||a.privilege||' ON '||a.owner||'.'||a.table_name||' TO '||a.grantee||';'  
from dba_tab_privs a
where owner in ('CRPDTA','CRPCTL');
