--/**************************************************************************************************************
-- * Managing historical data
-- * Name: dbo.usp_PurgeOldData
-- * Purpose: Purge data over 90 days old
-- *************************************************************************************************************/

USE [BaselineData];
GO
IF OBJECTPROPERTY(OBJECT_ID(N'usp_PurgeOldData'), 'IsProcedure') = 1
    DROP PROCEDURE usp_PurgeOldData;
GO

CREATE PROCEDURE dbo.usp_PurgeOldData (
    @PurgeWaits SMALLINT
)
AS
    BEGIN;
        IF @PurgeWaits IS NULL
            BEGIN;
                RAISERROR(N'Input parameters cannot be NULL', 16, 1);
                RETURN;
            END;

        DELETE FROM [dbo].[WaitStats]
        WHERE [CaptureDate] < GETDATE() - @PurgeWaits;
    END;
