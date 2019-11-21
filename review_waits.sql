--/**************************************************************************************************************
-- * Reviewing wait statistics data
-- * Review the last 30 days' data
-- * Review the top wait for each collected data set
-- *************************************************************************************************************/

--Review the last 30 days' data
SELECT *
FROM [dbo].[WaitStats]
WHERE [CaptureDate] > GETDATE() - 30
ORDER BY [RowNum];


--Review the top wait for each collected data set
SELECT [w].[CaptureDate]
      ,[w].[WaitType]
      ,[w].[Percentage]
      ,[w].[Wait_S]
      ,[w].[WaitCount]
      ,[w].[AvgWait_S]
FROM [dbo].[WaitStats] w
JOIN (
    SELECT MIN([RowNum]) AS [RowNum]
          ,[CaptureDate]
    FROM [dbo].[WaitStats]
    WHERE [CaptureDate] IS NOT NULL
    AND [CaptureDate] > GETDATE() - 30
    GROUP BY [CaptureDate]
     ) m 
ON [w].[RowNum] = [m].[RowNum]
ORDER BY [w].[CaptureDate];


--Select top 1000 rows
SELECT TOP (1000) [RowNum]
      ,[CaptureDate]
      ,[WaitType]
      ,[Wait_S]
      ,[Resource_S]
      ,[Signal_S]
      ,[WaitCount]
      ,[Percentage]
      ,[AvgWait_S]
      ,[AvgRes_S]
      ,[AvgSig_S]
FROM [BaselineData].[dbo].[WaitStats];

--/**************************************************************************************************************
-- * Analyze historical wait statistics using sys.dm_os_wait_stats
-- * NOTE: wait times are running totals, accumulated across all threads and sessions since server start
-- * 
-- *************************************************************************************************************/

--check SQL Server start time - 2008 and higher
SELECT sqlserver_start_time
FROM sys.dm_os_sys_info;

--Manually reset historical wait statistics
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR); 


/*
Options for clearing, capturing, and reviewing this data:

Option 1:
• Never clear wait statistics
• Capture weekly (at the end of any business day)
• Review weekly

Option 2:
• Clear wait statistics on Sunday nights (or after a full weekly backup)
• Capture daily at the end of the business day
• Review daily, checking to see if the percentages for wait types vary throughout the week

Option 3:
• Clear wait statistics nightly (after full or differential backups complete)
• Capture daily, at the end of the business day (optional: capture after any evening or
  overnight processing)
• Review daily, checking to see how the waits and their percentages vary throughout the
  week (and throughout the day if capturing more than once a day)
*/
