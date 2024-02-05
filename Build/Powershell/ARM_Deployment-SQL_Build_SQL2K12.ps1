param (
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string]$storageAccountName,
    [string]$sasTokenBuildContainer,
    [string]$sasTokenMigrationContainer,
    [int]$dbCount 
)


$ErrorActionPreference = "Stop"
# Disable Internet Explorer Enhanced Security Configuration

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
   # Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green

}

# Disable IE ESC
Disable-InternetExplorerESC

# Enable SQL Server ports on the Windows firewall

function Add-SqlFirewallRule {

    $fwPolicy = $null
    $fwPolicy = New-Object -ComObject HNetCfg.FWPolicy2
    
    $NewRule = $null
    $NewRule = New-Object -ComObject HNetCfg.FWRule
    
    $NewRule.Name = "SqlServer"

    # TCP
    $NewRule.Protocol = 6
    $NewRule.LocalPorts = 1433
    $NewRule.Enabled = $True
    $NewRule.Grouping = "SQL Server"

    # ALL
    $NewRule.Profiles = 7

    # ALLOW
    $NewRule.Action = 1

    # Add the new rule
    $fwPolicy.Rules.Add($NewRule)
}

Add-SqlFirewallRule

#Set Veriables
$InstallPath = 'C:\Install'
$BackupPath = 'C:\Backups'

#Create Folders for Labs and Installs
mkdir -Path $InstallPath
mkdir -Path $BackupPath
mkdir -Path "C:\Data"


#Download Scripts
function DownloadWithRetry([string] $url, [string] $downloadLocation, [int] $retries)
{
    while($true)
    {
        try
        {
            Invoke-WebRequest $url -OutFile $downloadLocation
            Write-Host "Download '$url'completed"
            break
        }
        catch
        {
            $exceptionMessage = $_.Exception.Message
            Write-Host "Failed to download '$url': $exceptionMessage"
            if ($retries -gt 0) {
                $retries--
                Write-Host "Waiting 10 seconds before retrying. Retries left: $retries"
                Start-Sleep -Seconds 10
 
            }
            else
            {
                $exception = $_.Exception
                throw $exception
            }
        }
    }
}

$SourcefilePath = "https://$storageAccountName.blob.core.windows.net/build/DB_SQL2K12_Build.zip$sasTokenBuildContainer"
DownloadWithRetry $SourcefilePath "$InstallPath\DB_SQL2K12_Build.zip"  10


Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "$InstallPath\DB_SQL2K12_Build.zip" $BackupPath


#Start SQL Service and wait
Start-service -Name 'MSSQLSERVER' -Verbose
Start-Sleep -s 90

# Create a file share for DMS
mkdir -Path "C:\FILESHARE"
cmd.exe /c "NET SHARE FILESHARE=C:\FILESHARE /grant:Everyone,FULL"

Stop-Service -Name 'MSSQLSERVER' -Force
$Svc = Get-WmiObject win32_service -filter "name='MSSQLSERVER'"
$Svc.Change($Null, $Null, $Null, $Null, $Null, $Null, ".\$adminUsername", "$AdminPassword")
Start-Service -Name 'MSSQLSERVER'
Start-Sleep -s 160


#Run SQL Cmds
sqlcmd -S "(local)" -U $AdminUsername -P $AdminPassword -i "$BackupPath\DB_SQL2K12_Build\1-RESTORE Databases.sql" -v dbCount = "$($dbCount)"

#load assemblies SMO
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null

# create SQL credential for migration container access

$serverConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection("localhost", $AdminUsername, $AdminPassword)
$server = New-Object Microsoft.SqlServer.Management.SMO.Server($serverConnection)
$credential = New-Object Microsoft.SqlServer.Management.Smo.Credential($server.ConnectionContext, "MigrationContainerCred")
$credential.Create($storageAccountName, $sasTokenMigrationContainer)

$ContainerMigrationUri = "$storageAccountName.blob.core.windows.net/migration"
sqlcmd -S "(local)" -U $AdminUsername -P $AdminPassword -i "$BackupPath\DB_SQL2K12_Build\2-CREATE_BACKUP_JOBS.sql" -v dbCount = "$($dbCount)" -v containerUri = "$($ContainerMigrationUri)" 




