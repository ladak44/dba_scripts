

select 'drop table TESTDTA.'||table_name||' purge;' from dba_tables  where owner = 'TESTDTA' 
and table_name not in ('F0911','F554347','F41511','F4211','F0911Z1','F43199','F554231') ;

