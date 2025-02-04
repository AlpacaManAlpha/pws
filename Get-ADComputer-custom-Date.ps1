# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

﻿$DaysInactive = 30

$time = (Get-Date).Adddays(-($DaysInactive))

Get-ADComputer -Filter 'operatingsystem -notlike "*server*" -and enabled -eq "true" -and LastLogonTimeStamp -lt $time '`
-Properties Name,Operatingsystem,OperatingSystemVersion,LastLogon |
Sort-Object -Property Operatingsystem |
Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,@{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}} |
#Export-CSV C:\Service\Computers.csv -NoTypeInformation |
Out-GridView
Read-Host