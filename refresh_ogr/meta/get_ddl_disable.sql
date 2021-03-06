set heading off
set linesize 300
set escape off
set echo off

COL echo NOPRINT NEW_VALUE v_echo


SELECT 'set echo on' v_echo FROM DUAL;


select 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||';'  
from dba_constraints 
WHERE  owner = UPPER('QADTA') and constraint_type = 'P'
AND    table_name IN (
'F556202',
'F41514',
'F0008',
'F0010',
'F0111',
'F01151',
'F0116',
'F0150',
'F03B11',
'F0411',
'F060116',
'F0902',
'F1201',
'F1202',
'F3111',
'F3112',
'F3460',
'F3711',
'F38010',
'F38011',
'F38012',
'F38013',
'F38014',
'F38111',
'F38112',
'F40500',
'F4070',
'F4071',
'F4074',
'F4092',
'F4094',
'F41002',
'F4101',
'F41011',
'F41021',
'F41022',
'F4104',
'F4105',
'F4106',
'F4111',
'F41511',
'F4201',
'F4211',
'F42119',
'F4301',
'F4311',
'F4801',
'F4801T',
'F49211',
'F49219',
'F0011',
'F0013',
'F0014',
'F0015',
'F40941',
'F40942',
'F40943',
'F4107',
'F4229',
'F550312',
'F4076',
'F550996',
'F0115',
'F41291',
'F1755',
'F41003',
'F554237',
'F40540',
'F4321',
'F554101',
'F1752',
'F3411',
'F3412',
'F43008',
'F43099',
'F554501',
'F554503',
'F1620',
'F30008',
'F3002',
'F30026',
'F3003',
'F1217',
'F42199',
'F553402',
'F0413',
'F0414',
'F1113',
'F40205',
'F41500',
'F41061',
'F4215',
'F4945',
'F4960',
'F4981',
'F1207',
'F41112',
'F4209',
'F554118',
'F42019',
'F0101Z2',
'F46011',
'F4961',
'F0006_ADT',
'F0012_ADT',
'F03012_ADT',
'F0401_ADT',
'F0901_ADT',
'F4008_ADT',
'F4072_ADT',
'F4075_ADT',
'F4095_ADT',
'F4096_ADT',
'F5509176',
'F5541515',
'F554506',
'F4102_ADT',
'F0101_ADT',
'F550304',
'F554103',
'F03B14',
'F554900',
'F4006',
'F4906',
'F4930',
'F4941',
'F49501',
'F554901',
'F554902',
'F554904',
'F554905',
'F554915',
'F554922',
'F4931',
'F556103_ADT',
'F554347',
'F554231',
'F554231H',
'F550005',
'F550006',
'F554113',
'F0025',
'F554217')
union
select 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||';'  
from dba_constraints 
WHERE  owner = UPPER('QACTL') and constraint_type = 'P'
AND    table_name IN ('F0004','F0005_ADT')
UNION 
select 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||';'  
from dba_constraints 
WHERE  owner      = UPPER('DD910')
AND    table_name IN ('F9210')
UNION
select 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||';'  
from dba_constraints 
WHERE  owner      = UPPER('SY910')
AND    table_name IN ('F0092');

SELECT 'quit;' v_quit FROM DUAL;


--spool off


quit;
