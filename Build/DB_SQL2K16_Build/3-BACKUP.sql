DECLARE @URL_Backup nvarchar(355)
DECLARE @CMD_Backup nvarchar(500)
DECLARE @URL_Container nvarchar(255)=N'https://sqlhacksa2o4ypnydkh4hu.blob.core.windows.net/backups'
Set @URL_Backup = @URL_Container+'/'+DB_NAME()+'/'+DB_NAME()+FORMAT(GETDATE(),'yyyyMMdd_HHmmss')+'.bak'

SET  @CMD_Backup ='BACKUP DATABASE ['+DB_NAME()+'] 
TO  URL = N'''+@URL_Backup+''' WITH NOFORMAT, NOINIT,  NAME = N'''+DB_NAME()+'-full Database Backup'', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10'

exec sp_executesql  @CMD_Backup


GO


DECLARE @URL_Backup nvarchar(355)
DECLARE @CMD_Backup nvarchar(500)
DECLARE @URL_Container nvarchar(255)=N'https://sqlhacksa2o4ypnydkh4hu.blob.core.windows.net/backups'
Set @URL_Backup = @URL_Container+'/'+DB_NAME()+'/'+DB_NAME()+FORMAT(GETDATE(),'yyyyMMdd_HHmmss')+'.trn'

SET  @CMD_Backup ='BACKUP LOG ['+DB_NAME()+'] 
TO  URL = N'''+@URL_Backup+''' WITH NOFORMAT, NOINIT,  NAME = N'''+DB_NAME()+'-Log Database Backup'', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10'

exec sp_executesql  @CMD_Backup