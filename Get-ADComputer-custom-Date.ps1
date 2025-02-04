$DaysInactive = 30

$time = (Get-Date).Adddays(-($DaysInactive))

Get-ADComputer -Filter 'operatingsystem -notlike "*server*" -and enabled -eq "true" -and LastLogonTimeStamp -lt $time '`
-Properties Name,Operatingsystem,OperatingSystemVersion,LastLogon |
Sort-Object -Property Operatingsystem |
Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,@{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}} |
#Export-CSV C:\Service\Computers.csv -NoTypeInformation |
Out-GridView
Read-Host