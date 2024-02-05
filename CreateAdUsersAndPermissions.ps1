#Connect-AzAccount
#Install-Module -Name AzureAD
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted


$user_group="SQLHackUsers"
$SharedRG ="SQLHACK-SHARED"
$VmsRG ="SQLHACK-TEAM_VMs"

$group = get-AzAdgroup -DisplayName $user_group

if(!$group)
{

$group= New-AzADGroup -DisplayName $user_group -MailNickname $user_group
}
$username="sqlhackuser"
$domain="1dayopenhack.biz"

$count=1..25

$groupid=$group.Id

foreach ($i in $count)
{
    $i_string = $i | % tostring 00
    $password="&sqlhack@demo_"+$i_string+"!"
    $securepassword= ConvertTo-SecureString $password -AsPlainText -force
    $upn=$username+$i_string +"@"+$domain
    $member=New-AzADUser -DisplayName $username$i_string  -Password $securepassword  -AccountEnabled $true -MailNickname $username$i_string  -UserPrincipalName $upn
    Add-AzADGroupMember -TargetGroupObjectId $groupid -MemberObjectId $member.Id
     
    }
# Create SQL MI Admin
    $username ="sqlmiadmin"
    $password = "Foso2272#OH2903"
    $securepassword= ConvertTo-SecureString $password -AsPlainText -force
    $upn=$username+"@"+$domain
    $member=New-AzADUser -DisplayName $username$i_string  -Password $securepassword  -AccountEnabled $true -MailNickname $username$i_string  -UserPrincipalName $upn


    $username ="adminuser"
    $password = "#SQLm2cAdmin@oh!!"
    $securepassword= ConvertTo-SecureString $password -AsPlainText -force
    $upn=$username+"@"+$domain
    $member=New-AzADUser -DisplayName $username$i_string  -Password $securepassword  -AccountEnabled $true -MailNickname $username$i_string  -UserPrincipalName $upn

#Get-AzRoleDefinition | Format-Table -Property Name, IsCustom, Id

New-AzRoleAssignment -ObjectId $groupid -RoleDefinitionName Reader -Scope (Get-AzResourceGroup -Name $SharedRG).ResourceId
New-AzRoleAssignment -ObjectId $groupid -RoleDefinitionName Reader -Scope (Get-AzResourceGroup -Name $VmsRG).ResourceId


#get SQL MI Name
$sqlmi = Get-AzSqlInstance -ResourceGroupName $SharedRG | Select-object -First 1
New-AzRoleAssignment -ObjectId $groupid -RoleDefinitionName Contributor -Scope ($sqlmi).Id
#Get storage account info
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $SharedRG | Select-object -First 1
New-AzRoleAssignment -ObjectId $groupid -RoleDefinitionName Contributor -Scope ($StorageAccount).Id


# assign contributor on DMS (classic)
New-AzRoleAssignment -ObjectId $groupid -RoleDefinitionName Contributor -Scope (Get-AzResource -Name sqlhack-migrationservice).ResourceId

# assign contributor on DMS (new)
New-AzRoleAssignment -ObjectId $groupid -RoleDefinitionName Contributor -Scope (Get-AzResource -Name sqlhack-dmsV2).ResourceId
