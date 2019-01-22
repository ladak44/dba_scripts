set heading off


set timing on
set echo on

exec dbms_stats.gather_table_stats (ownname=>'OPRDTA',tabname=>'F0911_C08',granularity =>'GLOBAL',CASCADE=> true,estimate_percent=>dbms_stats.auto_sample_size,degree=>dbms_stats.auto_degree);

quit;
