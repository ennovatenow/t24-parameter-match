DROP TABLE T24_PARAMETERS_SOURCE;
CREATE TABLE T24_PARAMETERS_SOURCE(
  TABLE_NAME NVARCHAR2(30),
  PARAMETER_NAME NVARCHAR2(255),
  COLUMN_NAME NVARCHAR2(30),
  M_VALUE NVARCHAR2(30),
  PARAMETER_VALUE NVARCHAR2(255)
);
DROP TABLE T24_TABLE_MAP;
CREATE TABLE T24_TABLE_MAP (
  TABLE_NAME NVARCHAR2(30),
  FUNCTIONAL_NAME NVARCHAR2(255)
);
CREATE OR REPLACE VIEW T24_PARAMETERS_SOURCE_PROFILE AS 
SELECT t.FUNCTIONAL_NAME, COUNT(1) COUNT
FROM   T24_PARAMETERS_SOURCE s,
       t24_table_map t
WHERE  s.table_name = t.table_name
GROUP  BY t.FUNCTIONAL_NAME;

DROP TABLE T24_PARAMETERS_DESTINATION;
CREATE TABLE T24_PARAMETERS_DESTINATION(
  TABLE_NAME NVARCHAR2(30),
  PARAMETER_NAME NVARCHAR2(255),
  COLUMN_NAME NVARCHAR2(30),
  M_VALUE NVARCHAR2(30),
  PARAMETER_VALUE NVARCHAR2(255)
);
CREATE OR REPLACE VIEW T24_PARAMETERS_DEST_PROFILE AS 
SELECT t.FUNCTIONAL_NAME, COUNT(1) COUNT
FROM   T24_PARAMETERS_DESTINATION d,
       t24_table_map t
WHERE  d.table_name = t.table_name
GROUP  BY t.FUNCTIONAL_NAME;

CREATE OR REPLACE VIEW T24_PARAMETERS_EXCEPTIONS_VIEW AS
select t.functional_name TABLE_NAME,
       s.parameter_name PARAMETER_NAME,
       upper(s.column_name||'M'||NVL(s.m_value,'1')) c_value,
       s.parameter_value source_parameter_value,
       d.parameter_value dest_parameter_value,
       decode(s.parameter_value,
                null, decode(d.parameter_value, null, 'Match', 'Source has no value but Destination has a value'),
                d.parameter_value, 'Match',
                decode(d.parameter_value, null, 'Source has a value but Destination has no value','Mismatch')) Message
from   t24_parameters_source s,
       t24_parameters_destination d,
       t24_table_map t
where  s.table_name = d.table_name
and    s.table_name = t.table_name
and    s.parameter_name = d.parameter_name
and    s.column_name = d.column_name
and    NVL(s.m_value,'1') = NVL(d.m_value,'1')
union
select t.functional_name TABLE_NAME,
       s.parameter_name PARAMETER_NAME,
       upper(s.column_name||'M'||NVL(s.m_value,'1')) c_value,
       s.parameter_value source_parameter_value,
       null dest_parameter_value,
       'Source has a value but Destination has no value' Message
from   t24_parameters_source s,
       t24_table_map t
where  s.table_name not in ( select distinct d.table_name from t24_parameters_destination d )
and    s.table_name = t.table_name
union
select t.functional_name TABLE_NAME,
       s.parameter_name PARAMETER_NAME,
       upper(s.column_name||'M'||NVL(s.m_value,'1')) c_value,
       s.parameter_value source_parameter_value,
       null dest_parameter_value,
       'Source has a value but Destination has no value' Message
from   t24_parameters_source s,
       t24_table_map t
where  not exists (
       select 1
       from   t24_parameters_destination d
       where  s.table_name = d.table_name
       and    s.parameter_name = d.parameter_name
       )
and    s.table_name = t.table_name       
union
select t.functional_name TABLE_NAME,
       s.parameter_name PARAMETER_NAME,
       upper(s.column_name||'M'||NVL(s.m_value,'1')) c_value,
       s.parameter_value source_parameter_value,
       null dest_parameter_value,
       'Source has a value but Destination has no value' Message
from   t24_parameters_source s,
       t24_table_map t
where  not exists (
       select 1
       from   t24_parameters_destination d
       where  s.table_name = d.table_name
       and    s.parameter_name = d.parameter_name
       and    upper(s.column_name||NVL(s.m_value,'1')) = upper(d.column_name||NVL(d.m_value,'1'))
       )
and    s.table_name = t.table_name       
union 
select t.functional_name TABLE_NAME,
       s.parameter_name PARAMETER_NAME,
       upper(s.column_name||'M'||NVL(s.m_value,'1')) c_value,
       s.parameter_value source_parameter_value,
       null dest_parameter_value,
       'Destination has a value but Source has no value' Message
from   t24_parameters_destination s,
       t24_table_map t
where  s.table_name not in ( select distinct d.table_name from t24_parameters_source d )
and    s.table_name = t.table_name
union
select t.functional_name TABLE_NAME,
       s.parameter_name PARAMETER_NAME,
       upper(s.column_name||'M'||NVL(s.m_value,'1')) c_value,
       s.parameter_value source_parameter_value,
       null dest_parameter_value,
       'Destination has a value but Source has no value' Message
from   t24_parameters_destination s,
       t24_table_map t
where  not exists (
       select 1
       from   t24_parameters_source d
       where  s.table_name = d.table_name
       and    s.parameter_name = d.parameter_name
       )
and    s.table_name = t.table_name       
union
select t.functional_name TABLE_NAME,
       s.parameter_name PARAMETER_NAME,
       upper(s.column_name||'M'||NVL(s.m_value,'1')) c_value,
       s.parameter_value source_parameter_value,
       null dest_parameter_value,
       'Destination has a value but Source has no value' Message
from   t24_parameters_destination s,
       t24_table_map t
where  not exists (
       select 1
       from   t24_parameters_source d
       where  s.table_name = d.table_name
       and    s.parameter_name = d.parameter_name
       and    upper(s.column_name||NVL(s.m_value,'1')) = upper(d.column_name||NVL(d.m_value,'1'))
       )
and    s.table_name = t.table_name;,218,0,218

CREATE OR REPLACE VIEW T24_PARAMETERS_MISMATCH_VIEW AS
SELECT * 
FROM   T24_PARAMETERS_EXCEPTIONS_VIEW 
WHERE  MESSAGE <> 'Match';

CREATE OR REPLACE VIEW T24_PARAMETERS_SUMMARY_VIEW AS
SELECT TABLE_NAME, 
       SUM(DECODE(UPPER(MESSAGE), 'MATCH', 1,0)) "Matched", 
       SUM(DECODE(UPPER(MESSAGE), 'MATCH', 0,1)) "Unmatched", 
       COUNT(1) "Total"
FROM   T24_PARAMETERS_EXCEPTIONS_VIEW
GROUP BY TABLE_NAME;
