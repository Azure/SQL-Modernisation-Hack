#Login-AzAccount

$CurrentDir = Split-Path $script:MyInvocation.MyCommand.Path

$TeamRG = "SQLHACK-TEAM_VMs"
$SharedRG="SQLHACK-SHARED"
$Script = 'Configure-TEAM_VMs.ps1'
$ScriptPath= (Join-Path $CurrentDir $Script)
$VWMName = "vm-TEAM01"

#Get storage account info
$StorageAccount = (Get-AzStorageAccount -ResourceGroupName $SharedRG).StorageAccountName  | Select-object -First 1
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $SharedRG -Name $StorageAccount
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $Key0
$SASURIKey= (New-AzStorageContainerSASToken -Name "build" -Policy "Build-Policy" -Context $Context)

$JsonSASUriContainerBuild = $SASURIKey | ConvertTo-Json

#$servers = Get-AzResource -ResourceGroupName $TeamRG -ResourceType Microsoft.Compute/virtualMachines

#ForEach ($Server in $servers)#
#{
    Write-host $Server.Name
    #$VWMName = $Server.Name
    
    Invoke-AzVMRunCommand -ResourceGroupName $TeamRG -Name $VWMName -CommandId RunPowerShellScript -ScriptPath $ScriptPath -Parameter @{StorageAccount = $StorageAccount; SASURIKey = $JsonSASUriContainerBuild; Installed = "0" }
#}

