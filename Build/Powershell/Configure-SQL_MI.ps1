param (
    [string]$SharedRG,
    [string]$adminUsername,
    [string]$StorageAccount,
    [string]$sqlmiFDQN,
    [String]$adminPassword,
    [string]$SASUriKey
)



Write-Host -BackgroundColor Black -ForegroundColor Yellow "##################### IMPORTANT: SSIS LAB BULD SCRIPT ######################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "This script will setup and install the SSIS and Perf Lab Databases."
Write-Host -BackgroundColor Black -ForegroundColor Yellow "IMPORTANT: Please only run after the build is complete"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

$ErrorActionPreference = "Stop"
#Set-ExecutionPolicy RemoteSigned -Force

If(-not(Get-InstalledModule Az -ErrorAction silentlycontinue)){
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

If(-not(Get-InstalledModule SQLServer -ErrorAction silentlycontinue)){
    Install-Module SQLServer -Confirm:$False -Repository PSGallery -Force
}


###############################################################################
# Copy locally TSQL scripts
###############################################################################
$Key = $SASURIKey | ConvertFrom-Json
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccount -SasToken $Key
Get-AzStorageBlob -Context $StorageContext.Context -Container "build" -Prefix "TSQL" | Get-AzStorageBlobContent -Force  -Destination "C:\Install"





###############################################################################
# Restore Databases
###############################################################################

Write-Host -BackgroundColor Black -ForegroundColor Yellow "################################# RESTORING DATABASES #######################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow " Databases will be restored and CLR will be enabled on the Managed Instance"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

# Restore Databases
 Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore databases on Managed Instance $sqlmiFDQN"

 # workaround to set the SAS key in the TSQL script, issue with = character in SQLCmd variables
$templateFileScript="C:\Install\TSQL_Scripts\RestoreDatabases.sql"
$updatedFileScript = $templateFileScript -creplace '.sql','_updated.sql'
(Get-Content  $templateFileScript) | 
Foreach-Object {$_ -creplace '--SASKEY--',$Key}  | 
Out-File $updatedFileScript

$StorageAccountURI = "https://$StorageAccount.blob.core.windows.net/build"
$VariableArray = @("StorageAccountURI=$StorageAccountURI" )
Invoke-Sqlcmd  -ServerInstance $sqlmiFDQN -Database "master"  -Username $adminUsername -Password $adminPassword -InputFile $updatedFileScript -Variable  $VariableArray
Remove-Item -Path $updatedFileScript -Force

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# Create jobs to simulate load for perfo lab
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating jobs on Managed Instance $sqlmiFDQN"
Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -InputFile "C:\Install\TSQL_Scripts\Perf_Create_workload_jobs.sql" -Username $adminUsername -Password $adminPassword
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# # Restore Database SharedMasterDataDB
# Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore SharedMasterDataDB database on Managed Instance $sqlmiFDQN"
# $blob = (Get-AzStorageBlob -Container build -Context $Context -Blob 'SharedMasterDataDB.bak').ICloudBlob.Uri.AbsoluteUri
# $Query = "if not exists (select 1 from sysdatabases where name = 'SharedMasterDataDB') RESTORE DATABASE [SharedMasterDataDB] FROM URL = '$blob'"
# Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
# Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# # Restore Database TenantDataDb
# Write-Host -BackgroundColor Black -ForegroundColor Yellow "Attempting restore TenantDataDb database on Managed Instance $sqlmiFDQN"
# $blob = (Get-AzStorageBlob -Container build -Context $Context -Blob 'TenantDataDb.bak').ICloudBlob.Uri.AbsoluteUri
# $Query = "if not exists (select 1 from sysdatabases where name = 'TenantDataDb') RESTORE DATABASE [TenantDataDb] FROM URL = '$blob'"
# Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password
# Write-Host -BackgroundColor Black -ForegroundColor Yellow "Complete."

# # Cleanup Credential used on SQLMI
# Write-Host -BackgroundColor Black -ForegroundColor Yellow "Cleaning Up........."

# del "*.bak"
# Remove-AzStorageContainer -Context $Context -Name build -Force
# $Query = "DROP CREDENTIAL [" + $SASUri.split('?')[0,2] + "]"
# Invoke-Sqlcmd -ServerInstance $sqlmiFDQN -Database "master" -Query $Query -Username $adminUsername -Password $Credentials.GetNetworkCredential().Password


# Write-Host -BackgroundColor Black -ForegroundColor Yellow "Databases Restored. Please Check databases 2008DW, LocalMasterDB, SharedMaterDB and TenantDataDB are present on the SQL MI"
