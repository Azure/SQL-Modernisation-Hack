DECLARE @Command nvarchar(max)
DECLARE @i int =1
DECLARE @i_string varchar(2)

WHILE (@i<=$(dbCount))
BEGIN
SELECT @i_string = convert(varchar(2), @i)
SELECT @i_string = REPLICATE('0', 2 - DATALENGTH(@i_string )) + @i_string 

    -- Restore TenantDataDb Database
    SET @Command =N'USE MASTER;
    CREATE LOGIN [TEAM'+@i_string+'] WITH PASSWORD=N''TEAM'+@i_string+''', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
    RESTORE DATABASE [TEAM'+@i_string+'_TenantDataDb] FROM  DISK = N''C:\Backups\DB_SQL2K12_Build\TenantDataDb.bak'' WITH  FILE = 1,  MOVE N''TenantDataDb_Data'' TO N''F:\data\TEAM'+@i_string+'_TenantDataDb.mdf'',  MOVE N''TenantDataDb_Log'' TO N''F:\log\TEAM'+@i_string+'_TenantDataDb_log.ldf'',  NOUNLOAD,  STATS = 5;
    ALTER DATABASE [TEAM'+@i_string+'_TenantDataDb] SET RECOVERY FULL WITH NO_WAIT;'
    EXEC SP_EXECUTESQL @command
    SET @Command =N'USE [TEAM'+@i_string+'_TenantDataDb];
    CREATE USER [TEAM'+@i_string+'] FROM LOGIN [TEAM'+@i_string+']'
    SELECT @command
    EXEC SP_EXECUTESQL @command


    -- Restore SharedMasterDataDB database
    SET @Command =N'USE MASTER;
    RESTORE DATABASE [TEAM'+@i_string+'_SharedMasterDataDB] FROM  DISK = N''C:\Backups\DB_SQL2K12_Build\SharedMasterDataDB.bak'' WITH  FILE = 1,  MOVE N''SharedMasterDataDB_Data'' TO N''F:\data\TEAM'+@i_string+'_SharedMasterDataDB.mdf'',  MOVE N''SharedMasterDataDB_Log'' TO N''F:\log\TEAM'+@i_string+'_SharedMasterDataDB_log.ldf'',  NOUNLOAD,  STATS = 5;
    ALTER DATABASE [TEAM'+@i_string+'_SharedMasterDataDB] SET RECOVERY FULL WITH NO_WAIT;'
    SELECT @command
    EXEC SP_EXECUTESQL @command
    SET @Command =N'USE [TEAM'+@i_string+'_SharedMasterDataDB];
    CREATE USER [TEAM'+@i_string+'] FROM LOGIN [TEAM'+@i_string+']'
    SELECT @command
    EXEC SP_EXECUTESQL @command

    -- Restore LocalMasterDataDb database
    SET @Command =N'USE MASTER;
    RESTORE DATABASE [TEAM'+@i_string+'_LocalMasterDataDB] FROM  DISK = N''C:\Backups\DB_SQL2K12_Build\LocalMasterDataDb.bak'' WITH  FILE = 1,  MOVE N''AdventureWorks2012'' TO N''F:\data\TEAM'+@i_string+'_LocalMasterDataDb.mdf'',  MOVE N''AdventureWorks2012_log'' TO N''F:\log\TEAM'+@i_string+'_LocalMasterDataDb_log.ldf'',  NOUNLOAD,  STATS = 5;
    ALTER DATABASE [TEAM'+@i_string+'_LocalMasterDataDB] SET RECOVERY FULL WITH NO_WAIT;'
    EXEC SP_EXECUTESQL @command
    SET @Command =N'USE [TEAM'+@i_string+'_LocalMasterDataDb];
    CREATE USER [TEAM'+@i_string+'] FROM LOGIN [TEAM'+@i_string+']'
    SELECT @command
    EXEC SP_EXECUTESQL @command

    SELECT @i =@i+1
END
GO