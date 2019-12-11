--- insert into


set timing on
set echo on

alter session set PARALLEL_FORCE_LOCAL=true;

alter session enable parallel dml;

ALTER SESSION FORCE PARALLEL DML PARALLEL 8;

spool insert_into.log

insert into CRPDTA.F4074 select * from QADTA.F4074@JDE001Q_PDB  where ALUPMJ>118365;

commit;

insert into CRPDTA.F4211 select * from QADTA.F4211@JDE001Q_PDB where SDDGL>118365;

commit;

insert into CRPDTA.F42119 select * from QADTA.F42119@JDE001Q_PDB where SDDGL>118365;

commit;

insert into CRPDTA.F42199 select * from QADTA.F42199@JDE001Q_PDB where SLDGL>118365;

commit;

insert into CRPDTA.F49211 select * from QADTA.F49211@JDE001Q_PDB where UDUPMJ>118365;

commit;

insert into CRPDTA.F554248 select * from QADTA.F554248@JDE001Q_PDB where WFUPMJ>118365;

commit;

insert into CRPDTA.F47042 select * from QADTA.F47042@JDE001Q_PDB where SZUPMJ>118365;

commit;

insert into CRPDTA.F47041 select * from QADTA.F47041@JDE001Q_PDB where SYUPMJ>118365;

commit;

insert into CRPDTA.F550920H select * from QADTA.F550920H@JDE001Q_PDB where PADGJ>118365;

commit;


insert into CRPDTA.F554231H select * from QADTA.F554231H@JDE001Q_PDB where SZUPMJ>118365;

commit;

insert into CRPDTA.F5547012 select * from QADTA.F5547012@JDE001Q_PDB  where SZUPMJ>118365;

commit;

insert into CRPDTA.F5547011 select * from QADTA.F5547011@JDE001Q_PDB  where SYUPMJ>118365;

commit;

insert into CRPDTA.F550408H select * from QADTA.F550408H@JDE001Q_PDB  where EDUPMJ>118365;

commit;

insert into CRPDTA.F4311 select * from QADTA.F4311@JDE001Q_PDB where PDTRDJ>118365;

commit;

insert into CRPDTA.F43121 select * from QADTA.F43121@JDE001Q_PDB where PRTRDJ>118365;

commit;

insert into CRPDTA.F43199 select * from QADTA.F43199@JDE001Q_PDB where OLTRDJ>118365;

commit;

insert into CRPDTA.F4111 select * from QADTA.F4111@JDE001Q_PDB where ILDGL>118365;

commit;

insert into CRPDTA.F0018R select * from QADTA.F0018R@JDE001Q_PDB where EDDGJ>118365;

commit;

insert into CRPDTA.F0911 select * from QADTA.F0911@JDE001Q_PDB where GLDGJ>118365;

commit;

insert into CRPDTA.F0911R select * from QADTA.F0911R@JDE001Q_PDB where GLDKJ>118365;

commit;

insert into CRPDTA.F550911T select * from QADTA.F550911T@JDE001Q_PDB where ALDATE01>118365;

commit;

insert into CRPDTA.F550997 select * from QADTA.F550997@JDE001Q_PDB where PADGJ>118365;

commit;

insert into CRPDTA.F556201 select * from QADTA.F556201@JDE001Q_PDB where ELDGL>118365;

commit;

spool off
