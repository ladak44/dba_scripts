set heading off


create bigfile tablespace F0911_TABLESPACE;

create table OPRDTA.F0911_LOAD tablespace F0911_TABLESPACE compress for query high as select * from QADTA.F0911@JDE001Q.EM3.ORACLECLOUD.COM where 1=0;	


--spool off


quit;
