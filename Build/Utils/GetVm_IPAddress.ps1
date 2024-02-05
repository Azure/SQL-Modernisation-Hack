$TeamRG = "SQLHACK-TEAM_VMs"
"VM_Name;PublicIP"
Get-AzPublicIpAddress -ResourceGroupName $TeamRG | ForEach-Object{
$VM_Name = $_.Name -replace 'ip-',''

"$VM_Name;$($_.IpAddress)"
}