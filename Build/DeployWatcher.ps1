# Connect-AzAccount
# Get-AzSubscription



$SharedRG ="SQLHACK-SHARED"
$adminUsername="DemoUser"
$adminPassword = Read-Host "Please enter a 16 character Password. The password must be between 16 and 128 characters in length and must contain at least one number, one non-alphanumeric character, and one upper or lower case letter" -AsSecureString 



$CurrentDir = Split-Path $script:MyInvocation.MyCommand.Path

$sqlmi= Get-AzSqlInstance -ResourceGroupName $SharedRG | Select-object -First 1
$sqlmiFQDN = (Get-AzSqlInstance -ResourceGroupName $SharedRG).FullyQualifiedDomainName  | Select-object -First 1
$sqlmiDNSZone = $sqlmi.DnsZone
$sqlManagedInstanceName = $sqlmi.ManagedInstanceName

########################################################################################################
# Setup KeyVault for testing
# Setup KeyVault
$Random = Get-Random -Maximum 99999
$Keyvault = "sqlhack-keyvault-$Random"
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Checkin/Creating KeyVault ................................................"
# check if keyvault exists and create if not present 

If(-not (Get-AzKeyVault  -ResourceGroupName $SharedRG -ErrorVariable notPresent -ErrorAction Ignore)){
New-AzKeyVault -Name $Keyvault  -ResourceGroupName $SharedRG -Location $sqlmi.Location -EnableRbacAuthorization -SoftDeleteRetentionInDays 2
}
else {
    Write-Host "KeyVault already exists"
}
########################################################################################################

$kv = Get-AzKeyVault -ResourceGroupName $SharedRG| Select-object -First 1
$kvName= $kv.VaultName 

 Get-AzKeyVault -ResourceGroupName $SharedRG -VaultName $Keyvault


###################################################################
# Setup Data Explorer & Watcher
###################################################################
Write-Host -BackgroundColor Black -ForegroundColor Yellow "Creating Data Explorer ................................................"
$AdxClusterName= "adx-sqlhack-$Random"
$TemplateUri = (Join-Path $CurrentDir "ARM Templates\ARM Template - SQL Hackathon - ADX.json")
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri  -sqlmiFQDN $sqlmiFQDN -keyvault_name $kvName -sqlmiDnsZone $sqlmiDNSZone -sqlmiName $sqlManagedInstanceName -clusters_kustocluster_name $AdxClusterName -Name "WatcherSQLMonitoring" #$temp-AsJob 

# set permissions for the ADX database
$tenantId =(Get-AzTenant).Id
$watcher = Get-AzResource -ResourceType Microsoft.DatabaseWatcher/watchers -ResourceGroupName $SharedRG  | Select-object -First 1
$watcherPrincipalId = $watcher.Identity.PrincipalId

$kqlScript = ".add database [sqlmonitoringdb] admins ('aadapp=$watcherPrincipalId;$tenantId'); "
$TemplateUri = (Join-Path $CurrentDir "ARM Templates\ARM Template- Execute ADX script.json")
New-AzResourceGroupDeployment -ResourceGroupName $SharedRG -TemplateUri $TemplateUri  -ClusterName $AdxClusterName -kqlScript $kqlScript -Name "AddAdxPermission" #$temp-AsJob 

###################################################################
# configure KeyVault and create secrets
$currentAdmin = (Get-AzContext).Account.Id 
if (!(Get-AzRoleAssignment -SignInName $currentAdmin -Scope $kv.ResourceId -RoleDefinitionName "Key Vault Administrator"))
{
    New-AzRoleAssignment -RoleDefinitionName "Key Vault Administrator" -SignInName $currentAdmin -Scope $kv.ResourceId
    Write-Host "Role assignment created"
}


# Assign the Key Vault Secrets User role to the watcher managed identity
if (!(Get-AzRoleAssignment  -ObjectId $watcher.Identity.PrincipalId -Scope $kv.ResourceId -RoleDefinitionName "Key Vault Secrets User"))
{
    New-AzRoleAssignment -RoleDefinitionName "Key Vault Secrets User" -ObjectId $watcher.Identity.PrincipalId -Scope $kv.ResourceId
    Write-Host "Role assignment created"
}
else {
    Write-Host "Role assignment already exists"
}

# create a secret in the key vault
$secretName = "database-watcher-login-name-secret"
$secretValue = "watcher_user"
$secret = ConvertTo-SecureString -String $secretValue -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName -SecretValue $secret

$secretName = "database-watcher-password-secret"
Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName -SecretValue $adminPassword
