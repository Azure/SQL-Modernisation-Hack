param (
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string]$storageAccountName,
    [string]$sasToken,
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

Install-WindowsFeature -Name Failover-Clustering –IncludeManagementTools

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

New-NetFirewallRule -DisplayName "Allow TCP port 5022 inbound" -Direction inbound -Profile Any -Action Allow -LocalPort 5022 -Protocol TCP
New-NetFirewallRule -DisplayName "Allow TCP port 5022 outbound" -Direction outbound -Profile Any -Action Allow -LocalPort 5022 -Protocol TCP



function IfNotExistsCreateFolder([string] $folderPath)
{
    If(!(test-path $folderPath))
        {
            md -Path $folderPath 
        }

}

#Set Veriables
$InstallPath = 'D:\Install'
$BackupPath = 'D:\Backups'
$DataPath = 'F:\Data'

#Create Folders for Labs and Installs
IfNotExistsCreateFolder $InstallPath
IfNotExistsCreateFolder $BackupPath
IfNotExistsCreateFolder $DataPath


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

$SourcefilePath = "https://$storageAccountName.blob.core.windows.net/build/DB_SQL2K16_Build.zip$sasToken"
DownloadWithRetry $SourcefilePath "$InstallPath\DB_SQL2K16_Build.zip"  10


Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "$InstallPath\DB_SQL2K16_Build.zip" $BackupPath


#Start SQL Service and wait
$Svc = Get-WmiObject win32_service -filter "name='MSSQLSERVER'"
$Svc.Change($Null, $Null, $Null, $Null, $Null, $Null, ".\$adminUsername", "$AdminPassword")
Start-Service -Name 'MSSQLSERVER'
Start-Sleep -s 160

#Run SQL Cmds
sqlcmd -S "(local)" -U $AdminUsername -P $AdminPassword -i "$BackupPath\DB_SQL2K16_Build\1-RESTORE Databases.sql" -v dbCount = "$($dbCount)"
sqlcmd -S "(local)" -U $AdminUsername -P $AdminPassword -i "$BackupPath\DB_SQL2K16_Build\2-SETUP_MILINK.sql" -v password = "$($AdminPassword)"







