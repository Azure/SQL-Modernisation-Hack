<# A
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
#Select-AzSubscription -Tenant '3149cb37-c8a4-473d-becf-5b22cce27182' -SubscriptionId '4cbf3664-3873-4cd2-bd36-129282d24d71'

$CurrentDir = Split-Path $script:MyInvocation.MyCommand.Path

$TeamRG = "SQLHACK-TEAM_VMs"
$SharedRG ="SQLHACK-SHARED"
$VWMName = "vm-TEAM01" #VM used to execute the configuration
$adminUsername="DemoUser"
$adminPassword = Read-Host "Please enter a 16 character Password. The password must be between 16 and 128 characters in length and must contain at least one number, one non-alphanumeric character, and one upper or lower case letter" 

$Script = 'Powershell/Configure-SQL_MI.ps1'
$ScriptPath= (Join-Path $CurrentDir $Script)


#get SQL MI FQDN
$sqlmiFDQN = (Get-AzSqlInstance -ResourceGroupName $SharedRG).FullyQualifiedDomainName  | Select-object -First 1

#Get storage account info
$StorageAccount = (Get-AzStorageAccount -ResourceGroupName $SharedRG).StorageAccountName  | Select-object -First 1
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $SharedRG -Name $StorageAccount
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $Key0
$SASURIKey= (New-AzStorageContainerSASToken -Name "build" -Policy "Build-Policy" -Context $Context).TrimStart("?")

$JsonSASUriContainerBuild = $SASURIKey | ConvertTo-Json

$Message = "$(get-date -Format 'dd/MM/yyyy hh:mm:ss'): $VMName -- Configuration starting..."
write-host $Message
$out = Invoke-AzVMRunCommand -ResourceGroupName $TeamRG -Name $VWMName -CommandId RunPowerShellScript -ScriptPath $ScriptPath -Parameter @{SharedRG =$SharedRG ;adminUsername = $adminUsername;adminPassword = $adminPassword; StorageAccount = $StorageAccount; SASURIKey = $JsonSASUriContainerBuild; sqlmiFDQN  = $sqlmiFDQN }

if($out.value[1].Message)
{
    $status= "failed" 
    $ForegroundColor="Red"
    $message = $out.value[1].Message
}
else {
    $status= "successfull"
    $ForegroundColor="White"
    $message = $out.value[0].Message
}
$output =  "$(get-date -Format 'dd/MM/yyyy hh:mm:ss'): $VMName -- status: $status " + $message
Write-host $output - -ForegroundColor  $ForegroundColor

