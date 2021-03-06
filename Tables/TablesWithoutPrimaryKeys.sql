SELECT SCHEMA_NAME(schema_id) AS SchemaName,name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
ORDER BY SchemaName, TableName;



DECLARE @TempTable1 TABLE
(TableName nvarchar(200))

DECLARE @TempTable2 TABLE
(TableName nvarchar(200))

INSERT INTO @TempTable2
SELECT name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0



INSERT INTO @TempTable1 SELECT 'ABSENCE_CACHE'
INSERT INTO @TempTable1 SELECT 'ABSENCE_CURRENT'
INSERT INTO @TempTable1 SELECT 'ABSENCE_EXPORT'
INSERT INTO @TempTable1 SELECT 'ACTIVITY'
INSERT INTO @TempTable1 SELECT 'ACTIVITYMEDIA'
INSERT INTO @TempTable1 SELECT 'ADHERENCEEXCEPTION'
INSERT INTO @TempTable1 SELECT 'AUEMPLOYEEJOBTITLE'
INSERT INTO @TempTable1 SELECT 'AUTHACCESSRIGHT'
INSERT INTO @TempTable1 SELECT 'AUTHPRIVILEGE'
INSERT INTO @TempTable1 SELECT 'AUTHROLE'
INSERT INTO @TempTable1 SELECT 'AUTHROLEPRIVILEGE'
INSERT INTO @TempTable1 SELECT 'BPUSER'
INSERT INTO @TempTable1 SELECT 'CONTACTMETHOD'
INSERT INTO @TempTable1 SELECT 'EMPLOYEEAM'
INSERT INTO @TempTable1 SELECT 'EMPLOYEEDATASOURCE'
INSERT INTO @TempTable1 SELECT 'EMPLOYEEQUALITY'
INSERT INTO @TempTable1 SELECT 'EMPLOYEETEAMLEAD'
INSERT INTO @TempTable1 SELECT 'EMPLOYETIMEOFFALLOTMENT'
INSERT INTO @TempTable1 SELECT 'EMPLOYEETYPE'
INSERT INTO @TempTable1 SELECT 'EMPUSERPROPERTY'
INSERT INTO @TempTable1 SELECT 'FORECASTINSTANCE'
INSERT INTO @TempTable1 SELECT 'FORECASTTIMESERIES'
INSERT INTO @TempTable1 SELECT 'FORECASTUSAGE'
INSERT INTO @TempTable1 SELECT 'IMPORTDEVENT'
INSERT INTO @TempTable1 SELECT 'JOBTITLE'
INSERT INTO @TempTable1 SELECT 'MEDIA'
INSERT INTO @TempTable1 SELECT 'ORGANIZATION'
INSERT INTO @TempTable1 SELECT 'ORGANIZATIONDAY'
INSERT INTO @TempTable1 SELECT 'PAYPERIODEARNING'
INSERT INTO @TempTable1 SELECT 'PAYPERIODEARNINGFOREXPORT'
INSERT INTO @TempTable1 SELECT 'PAYPERIODSUMMARY'
INSERT INTO @TempTable1 SELECT 'PAYPERIODSUMMARYFOREXPORT'
INSERT INTO @TempTable1 SELECT 'PAYROLLADJUSTMENT'
INSERT INTO @TempTable1 SELECT 'PERSON'
INSERT INTO @TempTable1 SELECT 'PERSONCONTRCT'
INSERT INTO @TempTable1 SELECT 'PLANNEDEVENTTIMELINE'
INSERT INTO @TempTable1 SELECT 'PREDICTEDTIMESERIES'
INSERT INTO @TempTable1 SELECT 'PROFILETINESERIES'
INSERT INTO @TempTable1 SELECT 'QMEVALUATIONCATEGORY'
INSERT INTO @TempTable1 SELECT 'QMEVALUATIONFORM'
INSERT INTO @TempTable1 SELECT 'QMEVALUATIONQUESTION'
INSERT INTO @TempTable1 SELECT 'QMEVALUATIONSECTION'
INSERT INTO @TempTable1 SELECT 'QUEUE'
INSERT INTO @TempTable1 SELECT 'QUEUEHISTORYTIMESERIES'
INSERT INTO @TempTable1 SELECT 'REQUIREDTIMESERIES'
INSERT INTO @TempTable1 SELECT 'SHIFTASSIGNMENT'
INSERT INTO @TempTable1 SELECT 'SPQUEUE'
INSERT INTO @TempTable1 SELECT 'STRATEGICFORECAST'
INSERT INTO @TempTable1 SELECT 'SUPERVISOR'
INSERT INTO @TempTable1 SELECT 'TIMEENTRYEVENT'
INSERT INTO @TempTable1 SELECT 'TIMEOFFREQUESTCHOICE'
INSERT INTO @TempTable1 SELECT 'TIMERECORD'
INSERT INTO @TempTable1 SELECT 'TIMETRACKINGEVENT'
INSERT INTO @TempTable1 SELECT 'TIMEZONEAM'
INSERT INTO @TempTable1 SELECT 'USERDEFINEDATTRIBUTES'
INSERT INTO @TempTable1 SELECT 'WORKRESOURCEJOBTITLE'
INSERT INTO @TempTable1 SELECT 'WORKRESOURCEORGANIZATION'
INSERT INTO @TempTable1 SELECT 'USERDEFINEDATTRIBUTES'
INSERT INTO @TempTable1 SELECT 'REQUIREDTIMESERIES'
INSERT INTO @TempTable1 SELECT 'PREDICTEDTIMESERIES'
INSERT INTO @TempTable1 SELECT 'FORECASTTIMESERIES'





SELECT * 
FROM @TempTable2 ctpk
		INNER JOIN @TempTable1 tmptbl1	on ctpk.TableName = tmptbl1.TableName

