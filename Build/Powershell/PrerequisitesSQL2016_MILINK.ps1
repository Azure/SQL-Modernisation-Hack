New-Cluster -Name "CLU01" -AdministrativeAccessPoint None -Verbose -Force

Enable-SqlAlwaysOn -Path SQLSERVER:\SQL\legacysql2016\default -Force