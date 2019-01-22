
set timing on
set echo on

exec dbms_stats.gather_schema_stats (ownname=>'CRPDTA',granularity =>'GLOBAL',CASCADE=> true,estimate_percent=>dbms_stats.auto_sample_size,degree=>dbms_stats.auto_degree);

exec dbms_stats.gather_schema_stats (ownname=>'CRPCTL',granularity =>'GLOBAL',CASCADE=> true,estimate_percent=>dbms_stats.auto_sample_size,degree=>dbms_stats.auto_degree);

quit;
