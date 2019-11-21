--/***************************************************************************************************
--
-- Name: cre_BaselineData.sql 
--
-- Usage: Execute (F5) in SQL Server Management Studio 2008 or Above
--
-- Purpose: This script is used to create baseline database, table(s), and insert wait statistics.
--
-- Included: (1) Database, (2) Tables, (1) Operator, (1) Job, (1) Stored Procedure
--           BaselineData, WaitStats, WaitsToIgnore, PerfAdmin, CaptureWaitStats, usp_PurgeOldData 
--
-- Modification Log
-- Init     Date        Change
-- APM      08/30/2019  Created
-- APM      09/03/2019  Added WaitsToIgnore table to stuff benign waits
-- APM      09/04/2019  Updated CREATE DATABASE to include MAXDOP = 4 setting
-- APM      09/05/2019  Fixed expression MAX logic in data capture CTE, CaptureWaitStats Transact-SQL
-- APM      09/24/2019  Extended list of waits to ignore in CaptureTopWaits job
--
--***************************************************************************************************/

/* --Create BaselineData database to store baseline data-- */
USE [master];
GO
CREATE DATABASE [BaselineData] ON PRIMARY (
    NAME = N'BaselineData',
    FILENAME = N'D:\MSSQL13.MSSQLSERVER\MSSQL\DATA\UserDB\BaselineData.mdf',
    SIZE = 524288KB,
    FILEGROWTH = 524288KB
)   
LOG ON (
    NAME = N'BaselineData_log',
    FILENAME = N'D:\MSSQL13.MSSQLSERVER\MSSQL\DATA\UserDB\BaselineData_log.ldf',
    SIZE = 131072KB,
    FILEGROWTH = 524288KB
) ;
ALTER DATABASE [BaselineData] SET RECOVERY SIMPLE;
GO

USE [BaselineData]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 4;
GO

USE [BaselineData]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [BaselineData] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO

USE [BaselineData];
GO
EXEC sys.sp_addextendedproperty
@name = N'DatabaseDescription',
@value = N'Contains objects related to Database Engine baseline data.';

USE [BaselineData];
GO
SELECT * FROM sys.extended_Properties;


/* --Create WaitStats table to collect the data-- */
USE [BaselineData];
GO
IF NOT EXISTS ( SELECT * FROM [sys].[tables] WHERE [name] = N'WaitStats' AND [type] = N'U') CREATE TABLE [dbo].[WaitStats] (
    [RowNum] [BIGINT] IDENTITY(1, 1),
    [CaptureDate] [DATETIME],
    [WaitType] [NVARCHAR](120),
    [Wait_S] [DECIMAL](14, 2),
    [Resource_S] [DECIMAL](14, 2),
    [Signal_S] [DECIMAL](14, 2),
    [WaitCount] [BIGINT],
    [Percentage] [DECIMAL](4, 2),
    [AvgWait_S] [DECIMAL](14, 2),
    [AvgRes_S] [DECIMAL](14, 2),
    [AvgSig_S] [DECIMAL](14, 2)
) ;
GO
CREATE CLUSTERED INDEX CLIX_WaitStats ON [dbo].[WaitStats] ([RowNum], [CaptureDate]) ;


/* --Create WaitsToIgnore table to stuff benign waits-- */
USE [BaselineData];
GO
IF NOT EXISTS ( SELECT * FROM sys.tables WHERE name = N'WaitsToIgnore' AND TYPE = N'U' ) CREATE TABLE dbo.WaitsToIgnore(WaitType SYSNAME PRIMARY KEY);

INSERT dbo.WaitsToIgnore(WaitType) 
VALUES (N'BROKER_EVENTHANDLER'), (N'BROKER_RECEIVE_WAITFOR'), (N'BROKER_TASK_STOP'), (N'BROKER_TO_FLUSH'), (N'BROKER_TRANSMITTER'), (N'CHECKPOINT_QUEUE'), (N'CHKPT'),
       (N'CLR_AUTO_EVENT'), (N'CLR_MANUAL_EVENT'), (N'CLR_SEMAPHORE'), (N'DBMIRROR_DBM_EVENT'), (N'DBMIRROR_EVENTS_QUEUE'), (N'DBMIRROR_WORKER_QUEUE'), (N'DBMIRRORING_CMD'), 
       (N'DIRTY_PAGE_POLL'), (N'DISPATCHER_QUEUE_SEMAPHORE'), (N'EXECSYNC'), (N'FSAGENT'), (N'FT_IFTS_SCHEDULER_IDLE_WAIT'), (N'FT_IFTSHC_MUTEX'), (N'HADR_CLUSAPI_CALL'),
       (N'HADR_FILESTREAM_IOMGR_IOCOMPLETIO(N'), (N'HADR_LOGCAPTURE_WAIT'), (N'HADR_NOTIFICATION_DEQUEUE'), (N'HADR_TIMER_TASK'), (N'HADR_WORK_QUEUE'), (N'KSOURCE_WAKEUP'), 
       (N'LAZYWRITER_SLEEP'), (N'LOGMGR_QUEUE'), (N'ONDEMAND_TASK_QUEUE'), (N'PWAIT_ALL_COMPONENTS_INITIALIZED'), (N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'), 
       (N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP'), (N'REQUEST_FOR_DEADLOCK_SEARCH'), (N'RESOURCE_QUEUE'), (N'SERVER_IDLE_CHECK'), (N'SLEEP_BPOOL_FLUSH'), 
       (N'SLEEP_DBSTARTUP'), (N'SLEEP_DCOMSTARTUP'), (N'SLEEP_MASTERDBREADY'), (N'SLEEP_MASTERMDREADY'), (N'SLEEP_MASTERUPGRADED'), (N'SLEEP_MSDBSTARTUP'), (N'SLEEP_SYSTEMTASK'), 
       (N'SLEEP_TASK'), (N'SLEEP_TEMPDBSTARTUP'), (N'SNI_HTTP_ACCEPT'), (N'SP_SERVER_DIAGNOSTICS_SLEEP'), (N'SQLTRACE_BUFFER_FLUSH'), (N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'),
       (N'SQLTRACE_WAIT_ENTRIES'), (N'WAIT_FOR_RESULTS'), (N'WAITFOR'), (N'WAITFOR_TASKSHUTDOW(N'), (N'WAIT_XTP_HOST_WAIT'), (N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG'), 
       (N'WAIT_XTP_CKPT_CLOSE'), (N'XE_DISPATCHER_JOIN'), (N'XE_DISPATCHER_WAIT'), (N'XE_TIMER_EVENT')
;


/* --Create PerfAdmin Operator for CaptureWaitStats Job-- */
USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator 
    @name=N'PerfAdmin', 
	@enabled=1
GO
