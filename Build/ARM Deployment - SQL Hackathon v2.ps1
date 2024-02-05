
<# 
#POWERSHELL ENVIRONMENTALS:
#=========================

#1. SET PS SCRIPT SECURITY:
#1.1 Set PS execution policy to Unrestricted so script can be run:
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#1.1 Confirm Exectution Policy changed to Unrestricted:
Get-ExecutionPolicy

#2. CONNECT PS SESSION TO TARGET AZURE SUBSCRIPTION:
#2.1 Run this to connect into Azure:
Connect-AzAccount

#2.2 Run this to get a list of Subscriptions you have access to:
Get-AzSubscription

#2.3 Replace <Tenant ID> and <Subscription ID> placeholders below then run: 
Select-AzSubscription -Tenant '<Tenant ID>' -SubscriptionId '<Subscription ID>'

#NOW RUN THE ENTIRE PS SCRIPT COMPLETING REQUESTED PARAMTERS AS PROMPTED.
#>
#Select-AzSubscription -Tenant '72f988bf-86f1-41af-91ab-2d7cd011db47' -SubscriptionId 'ab6dbbb5-ff85-4692-a99c-490f66eed14a'
#Select-AzSubscription -Tenant '4fc9c688-ad9c-4d58-85c7-d141d4989ac2' -SubscriptionId 'cfdd59e1-0a35-4577-a19b-6d6a44bcf2c4'

Write-Host -BackgroundColor Black -ForegroundColor Yellow "#################################################################################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "SQL Server Migration Hack Build Script"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "This script will build the enviroment for the SQL Server Hack and Labs"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "#################################################################################"
$CurrentDir = Split-Path $script:MyInvocation.MyCommand.Path
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Checking and Installing Az and SQL modules......................................."
$sourceRootPath ="C:\Sources"
#Set-ExecutionPolicy RemoteSigned -Force
If(-not(Get-InstalledModule Az -ErrorAction silentlycontinue)){
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
}



Write-Host -BackgroundColor Black -ForegroundColor Yellow "Setting Enviroment Variables....................................................."
$subscriptionID = (Get-AzContext).Subscription.id
$subscriptionName = (Get-AzContext).Subscription.Name

if(-not $subscriptionID) {   `
    $subscriptionMessage = "There is no selected Azure subscription. Please use Select-AzSubscription to select a default subscription";  `
    Write-Warning $subscriptionMessage ; return;}  `
else {   `
    $subscriptionMessage = ("Actually targeting Azure subscription: {0} - {1}." -f $subscriptionID, $subscriptionName)}
Write-Host -BackgroundColor Black -ForegroundColor Yellow $subscriptionMessage

if ((read-host "Please ensure this is the correct subscription. Press a to abort, any other key to continue.") -eq "a") {Return;}
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Continuing to build.................................................."

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Register Batch provider "
Register-AzResourceProvider -ProviderNamespace Microsoft.Batch

###################################################################
# Setup Vaiables
###################################################################
$DefaultValue = 3
if (($TeamVMCount = Read-Host "Please enter the number of Team VM's required (1-20) (default value: $DefaultValue)") -eq '') {$TeamVMCount = $DefaultValue}
# If ($TeamVMCount -gt 20)
# {
#     Write-Warning "Maximum number TEAM VM's is 20. Setting to 5 VM's"
#     $TeamVMCount = 5

# }

$DefaultValue = "WestEurope"
if (($Location = Read-Host "Please enter the Location of the Resource Groups. (default value: $DefaultValue)") -eq '') {$Location = $DefaultValue}
If (“NorthEurope”,”WestEurope”,”UKSouth”, "UKWest", "WestUS", "EastUS" -NotContains $Location  ) {Write-Warning "Unrecognised location. Setting to Default $DefaultValue" ; $Location = "NorthEurope"}

Write-Host -BackgroundColor Black -ForegroundColor Yellow "##################### IMPORTANT: MAKE A NOTE OF THE FOLLOWING USERNAME and PASSWORD ########################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "The username and password specified next, will be used to credentials to SQL, Managed Instance and any VM's"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"
$DefaultValue = "DemoUser"
$x = 4
do
    {$x = $x - 1
    if ($x -lt 3){write-host "Not enough characters. Retries remaining: " $x};
    if ($x -le 0) {write-host "Existing build. Please check username and retry..."; Exit};
    if (($adminUsername = Read-Host "Please enter an Admin username (more than 6 characters) (default value: $DefaultValue)") -eq '') {$adminUsername = $DefaultValue}
    }
while ($adminUsername.length -le 6)


$x = 4
do
    {$x = $x - 1
    if ($x -lt 3){write-host "Not enough characters. Retries remaining: " $x};
    if ($x -le 0) {write-host "Existing build. Please check password and retry..."; Exit};
    $adminPassword = Read-Host "Please enter a 16 character Password. The password must be between 16 and 128 characters in length and must contain at least one number, one non-alphanumeric character, and one upper or lower case letter" -AsSecureString
    }
while ($adminPassword.length -le 15)

###################################################################
# Setup Hack Resource Groups
###################################################################

Write-Host -BackgroundColor Black -ForegroundColor Yellow "##################### IMPORTANT: MAKE A NOTE OF THE FOLLOWING RESOURCE GROUPS ########################"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "The Resource groups will be used to store all the lab build"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "############################################################################################################"

$DefaultValue = "SQLHACK-SHARED"
if (($SharedRG = Read-Host "Please enter a Shared resource group name. (default value: $DefaultValue)") -eq '') {$SharedRG = $DefaultValue}

$notPresent = Get-AzResourceGroup -name $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {New-AzResourceGroup -Name $SharedRG -Location $Location} 

$DefaultValue = "SQLHACK-TEAM_VMs"
if (($TeamRG = Read-Host "Please enter a VM resource group name. (default value: $DefaultValue)") -eq '') {$TeamRG = $DefaultValue}

$notPresent =Get-AzResourceGroup -name $TeamRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if (!($notPresent)) {New-AzResourceGroup -Name $TeamRG -Location $Location}

$CurrentDir = Split-Path $script:MyInvocation.MyCommand.Path



###################################################################
# Setup Network and Storage account
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating Virtual Network................................................."
$templatePath= (Join-Path $CurrentDir "ARM Templates\ARM Template - SQL Hackathon - Network - v2.json")
$output = New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateFile $templatePath -Name "NetworkBuild" 


# Check if Vnet has been created
Get-AzVirtualNetwork -Name "$SharedRG-vnet" -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "VNET Failed to build. Please check and retry";return;}

# save the SQL Managed Instance FQDN
$uniqueRgValue = $output.Outputs['uniqueRgValue'].Value

###################################################################
# Setup SASURI
###################################################################
#Create Blob Storage Container and SASURI Key.
$StorageAccount = (get-AzStorageAccount -ResourceGroupName $SharedRG).StorageAccountName  | Select-object -First 1
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $SharedRG -Name $StorageAccount
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $Key0

#Create Container auditlogs
If(-not (Get-AzStorageContainer -Context $Context -Name auditlogs -ErrorAction Ignore)){
    $output = New-AzStorageContainer -Context $Context -Name auditlogs
}

#Create Container migration
If(-not (Get-AzStorageContainer -Context $Context -Name migration -ErrorAction Ignore)){
    $output = New-AzStorageContainer -Context $Context -Name migration
}

#Create Container Build
If(-not (Get-AzStorageContainer -Context $Context -Name build -ErrorAction Ignore)){
    $output = New-AzStorageContainer -Context $Context -Name build
}

#Create SASUri for Build Container
$storagePolicyName = "Build-Policy"
$expiryTime = (Get-Date).AddYears(1)

If(-not (Get-AzStorageContainerStoredAccessPolicy -Context $Context -Name build)){
    New-AzStorageContainerStoredAccessPolicy -Container build -Policy $storagePolicyName -Permission rl -ExpiryTime $expiryTime -Context $Context -StartTime(Get-Date) 
}
$SASUriContainerBuild = (New-AzStorageContainerSASToken -Name "build" -Policy $storagePolicyName -Context $Context)
$JsonSASUriContainerBuild = $SASUriContainerBuild | ConvertTo-Json

$storagePolicyName = "Migration-Policy"
If(-not (Get-AzStorageContainerStoredAccessPolicy -Context $Context -Name migration)){
    New-AzStorageContainerStoredAccessPolicy -Container migration -Policy $storagePolicyName -Permission rwld -ExpiryTime $expiryTime -Context $Context -StartTime(Get-Date) 
}
$SASUriMigrationContainer = (New-AzStorageContainerSASToken -Name "migration" -Policy $storagePolicyName -Context $Context -FullUri)
$JsonSASUriContainerMigration = $SASUriMigrationContainer| ConvertTo-Json
###################################################################################
# download and upload source file needed
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


If(!(test-path $sourceRootPath))
{
      New-Item -ItemType Directory -Force -Path $sourceRootPath
}
else
{
    Remove-Item $sourceRootPath -Force -Recurse
    New-Item -ItemType Directory -Force -Path $sourceRootPath

}
$CopyPath="$sourceRootPath\Downloads"
If(!(test-path $CopyPath))
{
      New-Item -ItemType Directory -Force -Path $CopyPath
}

DownloadWithRetry "https://aka.ms/ssmsfullsetup?clcid=0x409" "$CopyPath\SSMS-Setup-ENU.exe" 10
DownloadWithRetry "https://download.microsoft.com/download/C/6/3/C63D8695-CEF2-43C3-AF0A-4989507E429B/DataMigrationAssistant.msi" "$CopyPath\DataMigrationAssistant.msi" 10
DownloadWithRetry "https://go.microsoft.com/fwlink/?linkid=2124518" "$CopyPath\SSDT-Setup-ENU.exe" 10
DownloadWithRetry "https://go.microsoft.com/fwlink/?LinkId=708343" "$CopyPath\StorageExplore.exe" 10
DownloadWithRetry "https://download.visualstudio.microsoft.com/download/pr/3f56df9d-6dc0-4897-a49b-ea891f9ad0f4/076e353a29908c70e24ba8b8d0daefb8/windowsdesktop-runtime-3.1.21-win-x64.exe" "$CopyPath\windowsdesktop-runtime-3.1.21-win-x64.exe" 10
DownloadWithRetry "https://go.microsoft.com/fwlink/?linkid=2133900" "$CopyPath\sql-assessment-0.6.3.vsix" 10
DownloadWithRetry "https://go.microsoft.com/fwlink/?linkid=2099770" "$CopyPath\managed-instance-dashboard-0.4.2.vsix" 10


$SourcePath= (Join-Path $CurrentDir "DB_SSIS_Build\")
$TargetPath = "$sourceRootPath"
Copy-Item -Path $SourcePath -Destination $TargetPath -Recurse -Force
$SourcePath= (Join-Path $CurrentDir "DB_SQL2K12_Build\")
Compress-Archive -Path $SourcePath -DestinationPath "$TargetPath\DB_SQL2K12_Build.zip"
$SourcePath= (Join-Path $CurrentDir "DB_SQL2K16_Build\")
Compress-Archive -Path $SourcePath -DestinationPath "$TargetPath\DB_SQL2K16_Build.zip"

$SourcePath= (Join-Path $CurrentDir "LABS\")
Copy-Item -Path $SourcePath -Destination $TargetPath -Recurse -Force -Exclude "*.docx"
$SourcePath= (Join-Path $CurrentDir "DB_Perf\")
Copy-Item -Path $SourcePath -Destination $TargetPath -Recurse -Force
$SourcePath= (Join-Path $CurrentDir "Powershell\")
Copy-Item -Path $SourcePath -Destination $TargetPath -Recurse -Force
$SourcePath= (Join-Path $CurrentDir "TSQL_Scripts\")
Copy-Item -Path $SourcePath -Destination $TargetPath -Recurse -Force

# copy migration container SAS key to file
$TargetPathSASKey= (Join-Path $TargetPath "LABS\01-Data_Migration")
$SASUriMigrationContainer | out-file -FilePath "$TargetPathSASKey\SASKEY.txt" -Force




$filesToUpload = Get-ChildItem -File -Recurse -Path $sourceRootPath


        foreach ($x in $filesToUpload) {
            $targetPath = ($x.fullname.Substring($sourceRootPath.Length + 1)).Replace("\", "/")

            Write-Verbose "Uploading $("\" + $x.fullname.Substring($sourceRootPath.Length + 1)) to $("build" + " /" + $targetPath)"
            Set-AzStorageBlobContent -File $x.fullname -Container "build" -Blob $targetPath -Context $Context -Force
        }



###################################################################
# Setup SQL Legacy Servers
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating legacySQL2012 Server................................................."

$TemplateUri = (Join-Path $CurrentDir "ARM Templates\ARM Template - SQL Hackathon - SQL2k12.json")
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -adminPassword $adminpassword -adminUsername $adminUsername -storageAccount $StorageAccount -sasTokenBuildContainer $JsonSASUriContainerBuild -sasTokenMigrationContainer $Key0 -Name "LegacySQL2012" -dbCount $TeamVMCount  -AsJob 

Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating legacySQL2016 Server................................................."

$TemplateUri = (Join-Path $CurrentDir "ARM Templates\ARM Template - SQL Hackathon - SQL2K16.json")
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri  -adminPassword $adminpassword -adminUsername $adminUsername -storageAccount $StorageAccount -sasToken $JsonSASUriContainerBuild -Name "LegacySQL2K16" -dbCount $TeamVMCount  #-AsJob 

Restart-AzVM -ResourceGroupName  $SharedRG -Name legacysql2016
Write-host "legacysql2016 restarted "
$Script = 'Powershell\PrerequisitesSQL2016_MILINK.ps1'
$ScriptPath= (Join-Path $CurrentDir $Script)
Invoke-AzVMRunCommand -ResourceGroupName $SharedRG -Name legacysql2016 -CommandId RunPowerShellScript -ScriptPath $ScriptPath 

###################################################################
# Setup Data Migration Service V2
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating DMS, Datafactory, Keyvault, storage account shared resources.................................................."
$TemplateUri = (Join-Path $CurrentDir "ARM Templates\ARM Template - SQL Hackathon - Shared - v2.json")
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -Name "SharedServicesBuild" -AsJob 

# Setup KeyVault
$Random = Get-Random -Maximum 99999
$Keyvault = "sqlhack-keyvault-$Random"
If(-not (Get-AzKeyVault  -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction Ignore)){
New-AzKeyVault -Name $Keyvault  -ResourceGroupName $SharedRG -Location $Location
}
Get-AzKeyVault -Name $Keyvault -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {Write-Warning "sqlhack-keyvault Failed to build. Please check and retry";return;}


###################################################################
# Setup Managed Instance and ADF with SSIS IR
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating sqlhack-mi Managed Instance................................................."
$TemplateUri = (Join-Path $CurrentDir "ARM Templates\ARM Template - SQL Hackathon - Managed Instance- v2.json")
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri -adminPassword $adminpassword -adminUsername $adminUsername -location $location -createNSG 1 -createRT 1 -Name "ManagedInstanceBuild" -AsJob


###################################################################
# Setup Team VM's
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating $TeamVMCount Team Server(s).................................................."
$TemplateUri = (Join-Path $CurrentDir "ARM Templates\ARM Template - SQL Hackathon - Jump Servers - v2.json")

New-AzResourceGroupDeployment -ResourceGroupName $TeamRG -TemplateUri $TemplateUri -Name "TeamVMBuild" -vmCount $TeamVMCount -SharedResourceGroup $SharedRG -SASURIKey $JsonSASUriContainerBuild -StorageAccount $StorageAccount -adminPassword $adminpassword -adminUsername $adminUsername 
$AzureVMsRunning = Get-AzVM -ResourceGroupName $TeamRG -status | Where-Object {$_.PowerState -eq "VM running"}
$AzureVMsRunning | ForEach-Object -ThrottleLimit 22 -Parallel{

    Restart-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name
    Write-host "$($_.Name) restarted "
}
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Waiting for 3 minutes ........................................................."
start-sleep -s 180
Get-AzVM -ResourceGroupName $TeamRG -status | Where-Object {$_.PowerState -eq "VM running"} |Format-Table -Property  Name, PowerState

#configure VM's
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Start Vms configuration ........................................................."
$Script = 'Powershell\Configure-TEAM_VMs.ps1'
$ScriptPath= (Join-Path $CurrentDir $Script)
[string]$Installed = "1" # 1 to install tool and labs,  0 for labs only
$VMs = Get-AzVM -ResourceGroupName $TeamRG #-ResourceType Microsoft.Compute/virtualMachines

$VMs | ForEach-Object -ThrottleLimit 22 -Parallel {
    $RG = $_.ResourceGroupName
    $VMName= $_.Name
    $Message = "$(get-date -Format 'dd/MM/yyyy hh:mm:ss'): $VMName -- Configuration starting..."
    write-host $Message
    $out = Invoke-AzVMRunCommand -ResourceGroupName $RG -Name $VMName -CommandId RunPowerShellScript -ScriptPath $using:ScriptPath -Parameter @{StorageAccount = $using:StorageAccount; SASURIKey = $using:JsonSASUriContainerBuild; Installed = $using:Installed}
    #Formating the Output with the VM name
    if($out.value[1].Message)
    {
        $status= "failed" 
        $ForegroundColor="Red"
        $message = $out.value[1].Message
    }
    else {
        $status= "successfull"
        $ForegroundColor="White"
        $message = ""
    }
    $output =  "$(get-date -Format 'dd/MM/yyyy hh:mm:ss'): $VMName -- status: $status " + $message
    Write-host $output - -ForegroundColor  $ForegroundColor
}


Write-Host -BackgroundColor Black -ForegroundColor Yellow "Enviroment Build in progress. Please check RG deployments for errors."

Write-Warning "NOTE: THE FOLLOWING POST BUILD TASKS ARE REQUIRED."
Write-Warning "1. DataFactory Build Ok. You will need to start the SSIS integration runtime and enable AHUB"
Write-Warning "2. Restore databases for SSIS + Monitoring labs by running the Launch_SQL_MI_configuration.ps1. Choose a remote TEAM VM. Note: Only run once."
Write-Warning "3. All labs and documaention can be found on TEAMVM's in C:\_SQLHACK_\LABS"


