-- Post Build tasks to be run on the Managed instance
-- Please replace $(StorageAccountURI) with the blob container URL
-- Please replace --SASKEY-- with SAS key
-- The backups to restore can be found in the repository folder SQL SSIS Databases, you will need to upload these to a blob store
-- For more informatgion on how to restore databases from URL see https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-get-started-restore

USE master
GO
EXEC sp_configure 'CLR Enabled', 1
RECONFIGURE WITH OVERRIDE
GO

-- For more information 
USE [master]
GO

IF EXISTS (SELECT name FROM master.sys.credentials WHERE name = N'$(StorageAccountURI)')
DROP CREDENTIAL [$(StorageAccountURI)]
GO
CREATE CREDENTIAL [$(StorageAccountURI)] WITH IDENTITY='Shared Access Signature', SECRET='--SASKEY--';
SELECT 'Credential created' as Output
GO
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'LocalMasterDataDb')
BEGIN
    RESTORE DATABASE [LocalMasterDataDb] FROM URL = '$(StorageAccountURI)/DB_SSIS_Build/LocalMasterDataDb.bak';
    SELECT 'LocalMasterDataDb Database restored' as Output
END
GO
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'SharedMasterDataDb')
BEGIN
    RESTORE DATABASE [SharedMasterDataDb] FROM URL = '$(StorageAccountURI)/DB_SSIS_Build/SharedMasterDataDB.bak';
    SELECT 'SharedMasterDataDb Database restored' as Output
END
GO
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'TenantDataDb')
BEGIN
    RESTORE DATABASE [TenantDataDb] FROM URL = '$(StorageAccountURI)/DB_SSIS_Build/TenantDataDb.bak';  
    SELECT 'TenantDataDb Database restored' as Output
END    
GO
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'2008DW')
BEGIN
    RESTORE DATABASE [2008DW] FROM URL = '$(StorageAccountURI)/DB_SSIS_Build/2008DW.bak';
    SELECT '2008DW Database restored' as Output
END
GO
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'TenantCRM')
BEGIN
    RESTORE DATABASE [TenantCRM] FROM URL = '$(StorageAccountURI)/DB_Perf/TenantCRM_perf.bak';
    SELECT 'TenantCRM Database restored' as Output
END
GO
DROP CREDENTIAL [$(StorageAccountURI)];
GO