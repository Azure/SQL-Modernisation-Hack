
-- :setvar dbCount 3
-- :setvar storageName "sqlhacksa5ye3xwhzcqzjq"
-- :setvar containerUri "https://sqlhacksa5ye3xwhzcqzjq.blob.core.windows.net/migration"
-- :setvar containerSasKey "siUP3XulnF9kgFyIb7LsrAe2n8MCxcMLp+3pGbfjEmlhDkrzwJ/9xdhmaDZpjwjPb4tam1fcYe6T+AStoQhe4Q=="


DECLARE @Command nvarchar(max)
DECLARE @i int =1
DECLARE @i_string varchar(2)

WHILE (@i<=$(dbCount))
BEGIN
	SELECT @i_string = convert(varchar(2), @i)
	SELECT @i_string = REPLICATE('0', 2 - DATALENGTH(@i_string )) + @i_string 


	DECLARE @BackupJobCmd nvarchar(max)
	DECLARE @URL_Backup nvarchar(355)
	DECLARE @CMD_Backup nvarchar(max)
	DECLARE @URL_Container nvarchar(255)=N'https://$(containerUri)'
	Set @URL_Backup = @URL_Container+'/TEAM'+@i_string+'_TenantDataDb/TEAM'+@i_string+'_TenantDataDb.bak'

	SET  @CMD_Backup ='BACKUP DATABASE [TEAM'+@i_string+'_TenantDataDb] 
	TO  URL = N'''''+@URL_Backup+''''' WITH CREDENTIAL = ''''MigrationContainerCred'''', FORMAT, INIT,  NAME = N''''TEAM'+@i_string+'_TenantDataDb-full Database Backup'''',  NOREWIND, NOUNLOAD,  STATS = 10;
	'
	Set @URL_Backup = @URL_Container+'/TEAM'+@i_string+'_SharedMasterDataDB/TEAM'+@i_string+'_SharedMasterDataDB.bak'
	SET  @CMD_Backup = @CMD_Backup+'BACKUP DATABASE [TEAM'+@i_string+'_SharedMasterDataDB] 
	TO  URL = N'''''+@URL_Backup+''''' WITH CREDENTIAL = ''''MigrationContainerCred'''', FORMAT, INIT,  NAME = N''''TEAM'+@i_string+'_SharedMasterDataDBb-full Database Backup'''',  NOREWIND, NOUNLOAD,  STATS = 10;
	'
	Set @URL_Backup =  @URL_Container+'/TEAM'+@i_string+'_LocalMasterDataDB/TEAM'+@i_string+'_LocalMasterDataDB.bak'
	SET  @CMD_Backup =@CMD_Backup+'BACKUP DATABASE [TEAM'+@i_string+'_LocalMasterDataDB] 
	TO  URL = N'''''+@URL_Backup+''''' WITH CREDENTIAL = ''''MigrationContainerCred'''', FORMAT, INIT,  NAME = N''''TEAM'+@i_string+'_LocalMasterDataDB-full Database Backup'''',  NOREWIND, NOUNLOAD,  STATS = 10;'

	
	
	Set @BackupJobCmd = 'USE [msdb];
	BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
	BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''BACKUP_FULL_DB_TEAM'+@i_string+''', 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N''No description available.'', 
			@category_name=N''[Uncategorized (Local)]'', 
			@owner_login_name=N''sa'', @job_id = @jobId OUTPUT
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Backup'', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N''TSQL'', 
			@command=N'''+@CMD_Backup+''', 
			@database_name=N''master'', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	COMMIT TRANSACTION
	GOTO EndSave
	QuitWithRollback:
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
	EndSave:
	'
	select @BackupJobCmd
	exec sp_executesql  @BackupJobCmd
	Set @i=@i+1
END