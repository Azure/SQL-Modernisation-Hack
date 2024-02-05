

RESTORE DATABASE TEAM21_LocalMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_LocalMasterDataDB.bak' 
WITH MOVE 'LocalMasterDataDB_Data' TO 'C:\Data\LocalMasterDataDB_TEAM21.mdf', MOVE 'LocalMasterDataDB_Log' TO 'C:\Data\LocalMasterDataDB_TEAM21.ldf'


RESTORE DATABASE TEAM21_SharedMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_SharedMasterDataDB.bak' 
WITH MOVE 'SharedMasterDataDB_Data' TO 'C:\Data\SharedMasterDataDB_TEAM21.mdf'
, MOVE 'SharedMasterDataDB_Log' TO 'C:\Data\SharedMasterDataDB_TEAM21.ldf'

RESTORE DATABASE TEAM21_TenantDataDb 
FROM DISK = 'C:\Backups\TEAM20_TenantDataDb.bak' 
WITH MOVE 'TenantDataDb_Data' TO 'C:\Data\TenantDataDb_TEAM21.mdf'
, MOVE 'TenantDataDb_Log' TO 'C:\Data\TenantDataDb_TEAM21.ldf'




RESTORE DATABASE TEAM22_LocalMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_LocalMasterDataDB.bak' 
WITH MOVE 'LocalMasterDataDB_Data' TO 'C:\Data\LocalMasterDataDB_TEAM22.mdf', MOVE 'LocalMasterDataDB_Log' TO 'C:\Data\LocalMasterDataDB_TEAM22.ldf'


RESTORE DATABASE TEAM22_SharedMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_SharedMasterDataDB.bak' 
WITH MOVE 'SharedMasterDataDB_Data' TO 'C:\Data\SharedMasterDataDB_TEAM22.mdf'
, MOVE 'SharedMasterDataDB_Log' TO 'C:\Data\SharedMasterDataDB_TEAM22.ldf'

RESTORE DATABASE TEAM22_TenantDataDb 
FROM DISK = 'C:\Backups\TEAM20_TenantDataDb.bak' 
WITH MOVE 'TenantDataDb_Data' TO 'C:\Data\TenantDataDb_TEAM22.mdf'
, MOVE 'TenantDataDb_Log' TO 'C:\Data\TenantDataDb_TEAM22.ldf'


RESTORE DATABASE TEAM23_LocalMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_LocalMasterDataDB.bak' 
WITH MOVE 'LocalMasterDataDB_Data' TO 'C:\Data\LocalMasterDataDB_TEAM23.mdf', MOVE 'LocalMasterDataDB_Log' TO 'C:\Data\LocalMasterDataDB_TEAM23.ldf'


RESTORE DATABASE TEAM23_SharedMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_SharedMasterDataDB.bak' 
WITH MOVE 'SharedMasterDataDB_Data' TO 'C:\Data\SharedMasterDataDB_TEAM23.mdf'
, MOVE 'SharedMasterDataDB_Log' TO 'C:\Data\SharedMasterDataDB_TEAM23.ldf'

RESTORE DATABASE TEAM23_TenantDataDb 
FROM DISK = 'C:\Backups\TEAM20_TenantDataDb.bak' 
WITH MOVE 'TenantDataDb_Data' TO 'C:\Data\TenantDataDb_TEAM23.mdf'
, MOVE 'TenantDataDb_Log' TO 'C:\Data\TenantDataDb_TEAM23.ldf'


RESTORE DATABASE TEAM24_LocalMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_LocalMasterDataDB.bak' 
WITH MOVE 'LocalMasterDataDB_Data' TO 'C:\Data\LocalMasterDataDB_TEAM24.mdf', MOVE 'LocalMasterDataDB_Log' TO 'C:\Data\LocalMasterDataDB_TEAM24.ldf'


RESTORE DATABASE TEAM24_SharedMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_SharedMasterDataDB.bak' 
WITH MOVE 'SharedMasterDataDB_Data' TO 'C:\Data\SharedMasterDataDB_TEAM24.mdf'
, MOVE 'SharedMasterDataDB_Log' TO 'C:\Data\SharedMasterDataDB_TEAM24.ldf'

RESTORE DATABASE TEAM24_TenantDataDb 
FROM DISK = 'C:\Backups\TEAM20_TenantDataDb.bak' 
WITH MOVE 'TenantDataDb_Data' TO 'C:\Data\TenantDataDb_TEAM24.mdf'
, MOVE 'TenantDataDb_Log' TO 'C:\Data\TenantDataDb_TEAM24.ldf'

RESTORE DATABASE TEAM25_LocalMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_LocalMasterDataDB.bak' 
WITH MOVE 'LocalMasterDataDB_Data' TO 'C:\Data\LocalMasterDataDB_TEAM25.mdf', MOVE 'LocalMasterDataDB_Log' TO 'C:\Data\LocalMasterDataDB_TEAM25.ldf'


RESTORE DATABASE TEAM25_SharedMasterDataDB 
FROM DISK = 'C:\Backups\TEAM20_SharedMasterDataDB.bak' 
WITH MOVE 'SharedMasterDataDB_Data' TO 'C:\Data\SharedMasterDataDB_TEAM25.mdf'
, MOVE 'SharedMasterDataDB_Log' TO 'C:\Data\SharedMasterDataDB_TEAM25.ldf'

RESTORE DATABASE TEAM25_TenantDataDb 
FROM DISK = 'C:\Backups\TEAM20_TenantDataDb.bak' 
WITH MOVE 'TenantDataDb_Data' TO 'C:\Data\TenantDataDb_TEAM25.mdf'
, MOVE 'TenantDataDb_Log' TO 'C:\Data\TenantDataDb_TEAM25.ldf'


CREATE LOGIN [TEAM21] WITH PASSWORD=N'TEAM21', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

CREATE LOGIN [TEAM22] WITH PASSWORD=N'TEAM22', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [TEAM23] WITH PASSWORD=N'TEAM23', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [TEAM24] WITH PASSWORD=N'TEAM24', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [TEAM25] WITH PASSWORD=N'TEAM25', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [TEAM21_LocalMasterDataDB]
GO
CREATE USER [TEAM21] FOR LOGIN [TEAM21] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM21'
GO
USE [TEAM21_TenantDataDb]
GO
CREATE USER [TEAM21] FOR LOGIN [TEAM21] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM21'
GO
USE [TEAM21_SharedMasterDataDB]
GO
CREATE USER [TEAM21] FOR LOGIN [TEAM21] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM21'
GO


USE [TEAM22_LocalMasterDataDB]
GO
CREATE USER [TEAM22] FOR LOGIN [TEAM22] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM22'
GO
USE [TEAM22_TenantDataDb]
GO
CREATE USER [TEAM22] FOR LOGIN [TEAM22] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM22'
GO
USE [TEAM22_SharedMasterDataDB]
GO
CREATE USER [TEAM22] FOR LOGIN [TEAM22] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM22'
GO

USE [TEAM23_LocalMasterDataDB]
GO
CREATE USER [TEAM23] FOR LOGIN [TEAM23] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM23'
GO
USE [TEAM23_TenantDataDb]
GO
CREATE USER [TEAM23] FOR LOGIN [TEAM23] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM23'
GO
USE [TEAM23_SharedMasterDataDB]
GO
CREATE USER [TEAM23] FOR LOGIN [TEAM23] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM23'
GO

USE [TEAM24_LocalMasterDataDB]
GO
CREATE USER [TEAM24] FOR LOGIN [TEAM24] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM24'
GO
USE [TEAM24_TenantDataDb]
GO
CREATE USER [TEAM24] FOR LOGIN [TEAM24] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM24'
GO
USE [TEAM24_SharedMasterDataDB]
GO
CREATE USER [TEAM24] FOR LOGIN [TEAM24] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM24'
GO

USE [TEAM25_LocalMasterDataDB]
GO
CREATE USER [TEAM25] FOR LOGIN [TEAM25] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM25'
GO
USE [TEAM25_TenantDataDb]
GO
CREATE USER [TEAM25] FOR LOGIN [TEAM25] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM25'
GO
USE [TEAM25_SharedMasterDataDB]
GO
CREATE USER [TEAM25] FOR LOGIN [TEAM25] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'TEAM25'
GO
