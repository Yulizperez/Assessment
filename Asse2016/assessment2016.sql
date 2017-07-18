print '#####################################################'
--Nombre del servidor
print @@servername
print '#####################################################'
--Fecha de assement
print 'Fecha de ejecución; ' + ((CONVERT( VARCHAR(24), GETDATE(), 121)))+ char(10)

print '----------------INFORMACIÓN DE SISTEMA-------------------'+ CHAR(10)
print '### procesor'
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0' , N'ProcessorNameString' ;
go
set nocount on
declare @@var1 as char( 500), @@var2 as char (500)
--Diagnostic
	print @@version +' instance ''' + @@servicename +''' computer '''+ @@servername+''''+ char(10)

print '---ERROR LOG'
SELECT @@var1= cast(SERVERPROPERTY ('ErrorLogFileName') as char(500 ))
print @@var1
go

print '---LISTA DE DIRECTORIO ACTUAL'
--exec xp_cmdshell 'systeminfo'
declare @@var2 as char (500)
exec sp_configure 'xp_cmdshell', @@var2
reconfigure
go


Print '### Get file and size'
use master
SELECT dbid =rtrim( ltrim(d .database_id)), 
name=left(d .name, 45), autoclose = d.is_auto_close_on, ROUND( SUM(mf .size) * 8 / 1024, 0) Size_MBs ,
e.cmptlevel , 
e. version, reusewait =left(d. log_reuse_wait_desc,20 ), path_file=left(mf. physical_name,100 ), recovery_model=left( d.recovery_model_desc ,10), reusewait=left(d. log_reuse_wait_desc,20 ),
d.service_broker_guid , d. is_broker_enabled

FROM sys .master_files mf INNER JOIN sys. databases d 
ON d.database_id = mf.database_id inner join sysdatabases e on d.database_id =e. dbid
--WHERE d.database_id > 4 -- Skip system databases
GROUP BY d.database_id ,d. name ,mf .physical_name, e.cmptlevel , 
e. version, d.recovery_model_desc, d.log_reuse_wait_desc , d. service_broker_guid, d.is_broker_enabled, d.is_auto_close_on
ORDER BY d.name
go

print ''
print '### Properties'
exec xp_msver
go

xp_fixeddrives
go

print ''
print '---FUNCIONES DEL SERVIDOR FIJO DE SQL SERVER'
exec sp_helpsrvrole
go
 print '### procesor'
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0' , N'ProcessorNameString' ;
go

print '----------------INFORMACIÓN DE CONFIGURACIÓN-------------------'+ CHAR(10)
print '---CONFIGURACIÓN SQL---'
declare @@var1 as varchar( 100), @@var2 as varchar (100)
select @@var1= cast(name as varchar ),@@var2= cast(value as varchar ) 
from sys.configurations 
where name like '%max degree of parallelism%'
Print @@var1+ char(9 )+@@var2
go

declare @@var1 as varchar( 100), @@var2 as varchar (100)
	select @@var1= cast(name as varchar ),@@var2= cast(value as varchar ) 
	from sys.configurations 
	where name like '%max server memory%'
	Print @@var1+ char(9 )+@@var2
go

declare @@var1 as varchar( 100), @@var2 as varchar (100)
	select @@var1= cast(name as varchar ),@@var2= cast(value as varchar ) 
	from sys.configurations 
	where name like '%min server memory%'
	Print @@var1+ char(9 )+@@var2
go


declare @@var1 as varchar( 100), @@var2 as varchar (100)
	select @@var1= cast(name as varchar ),@@var2= cast(value as varchar ) 
	from sys.configurations 
	where name like '%xp_cmdshell%'
Print @@var1+ char(9 )+@@var2
exec sp_configure 'xp_cmdshell', 1
reconfigure
Print ''




print ''
print '### Top 10 waits' ;
WITH [Waits]
AS (SELECT wait_type, wait_time_ms / 1000.0 AS [WaitS],
          (wait_time_ms - signal_wait_time_ms) / 1000.0 AS [ResourceS],
           signal_wait_time_ms / 1000.0 AS [SignalS],
           waiting_tasks_count AS [WaitCount],
           100.0 *  wait_time_ms / SUM (wait_time_ms) OVER() AS [Percentage] ,
           ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats WITH ( NOLOCK)
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
        N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
        N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT',
        N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP' , N'REQUEST_FOR_DEADLOCK_SEARCH' ,
        N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
        N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP' ,
        N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
        N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
        N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
    AND waiting_tasks_count > 0)
SELECT
   top 10
    MAX (W1. wait_type) AS [WaitType],
    CAST (MAX (W1. Percentage) AS DECIMAL (5, 2)) AS [Wait Percentage],
    CAST (MAX (W1. WaitS) AS DECIMAL (16, 2)) AS [Wait_Sec],
    CAST (MAX (W1. ResourceS) AS DECIMAL (16, 2)) AS [Resource_Sec],
    CAST (MAX (W1. SignalS) AS DECIMAL (16, 2)) AS [Signal_Sec],
    MAX (W1. WaitCount) AS [Wait Count],
    CAST ((MAX (W1. WaitS) / MAX (W1 .WaitCount)) AS DECIMAL (16 ,4)) AS [AvgWait_Sec],
    CAST ((MAX (W1. ResourceS) / MAX (W1 .WaitCount)) AS DECIMAL (16 ,4)) AS [AvgRes_Sec],
    CAST ((MAX (W1. SignalS) / MAX (W1 .WaitCount)) AS DECIMAL (16 ,4)) AS [AvgSig_Sec]
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2. RowNum <= W1 .RowNum
GROUP BY W1.RowNum
HAVING SUM (W2 .Percentage) - MAX ( W1.Percentage ) < 99 -- percentage threshold
OPTION (RECOMPILE );

go


print '### space available'
SELECT DISTINCT volume=left(vs .volume_mount_point, 20), system_type=left(vs. file_system_type,15 ), volume_name=left(vs. logical_volume_name,30 ), left( CONVERT(DECIMAL (18, 2), vs.total_bytes/ 1073741824.0),15 ) AS [Size (GB)],
left(CONVERT( DECIMAL(18 ,2), vs.available_bytes /1073741824.0), 15) AS [Available(GB)], left( CAST(CAST (vs. available_bytes AS FLOAT)/ CAST(vs .total_bytes AS FLOAT ) AS DECIMAL( 18,2 )) * 100,15 ) AS [Free %]
FROM sys .master_files AS f WITH (NOLOCK) CROSS APPLY sys.dm_os_volume_stats (f. database_id, f .[file_id]) AS vs OPTION (RECOMPILE );
go


print '### Cluster nodes'
SELECT left( NodeName,30 ) 
FROM sys. dm_os_cluster_nodes 
WITH (NOLOCK) OPTION (RECOMPILE);
print ''
go

print '### Log file'
exec sp_readerrorlog 0, 1,'Logging SQL Server messages '

Print '### sql advanced configuration'
EXEC sp_configure 'show advanced option', '1';
reconfigure;
go

sp_configure;
go

set nocount off