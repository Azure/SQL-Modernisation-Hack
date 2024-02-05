DECLARE @Command nvarchar(max)
DECLARE @i int =1
DECLARE @i_string varchar(2)

WHILE (@i<=$(dbCount))
BEGIN
SELECT @i_string = convert(varchar(2), @i)
SELECT @i_string = REPLICATE('0', 2 - DATALENGTH(@i_string )) + @i_string 


SET @Command =N'USE MASTER;
CREATE LOGIN [TEAM'+@i_string+'] WITH PASSWORD=N''TEAM'+@i_string+''', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
RESTORE DATABASE [TEAM'+@i_string+'_GlobalDataDB] FROM  DISK = N''D:\Backups\DB_SQL2K16_Build\GlobalDataDB.bak'' WITH  FILE = 1,  MOVE N''GlobalDataDB_Data'' TO N''F:\data\TEAM'+@i_string+'_GlobalDataDB.mdf'',  MOVE N''GlobalDataDB_Log'' TO N''F:\log\TEAM'+@i_string+'_GlobalDataDB_log.ldf'',  NOUNLOAD,  STATS = 5;'
EXEC SP_EXECUTESQL @command
SET @Command =N'USE [TEAM'+@i_string+'_GlobalDataDB];
CREATE USER [TEAM'+@i_string+'] FROM LOGIN [TEAM'+@i_string+']'
SELECT @command
EXEC SP_EXECUTESQL @command
SELECT @i =@i+1
END
GO