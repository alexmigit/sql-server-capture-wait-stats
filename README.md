# SQL Server - Wait Statisics - Capture Baseline Data
Capture and analyze SQL Server historical wait statistics.


## Query Top Wait Statistics

:memo: The query_with_waits.sql file contains a query to retrieve the top resource waits from your SQL Server Database Engine.

## Create Baseline Database

:memo: To create a database to capture the baseline data from the waits query, execute the database_cre_BaselineData.sql file in SSMS

## SQL Server Agent Job to capture top resource waits

:memo: Use the Transact-SQL in Job_CaptureWaitStats_Step.sql in the Step Command window.

## Wait Statistics Research, Analysis & Reset

:memo: Use review_waits.sql for further analysis and manual reset of historical wait statistics.

## Stored Procedure

:memo: The usp_PurgeOldData.sql file contains the T-SQL to create the User Stored Procedure that can be executed to purge old waits data. 
