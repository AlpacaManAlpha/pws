# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$DaysInactive = 90
$time = (Get-Date).Adddays(-($DaysInactive))
$ComputerList = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and OperatingSystem -notlike "*server*"}
$ComputerList | Format-Table Name, DistinguishedName, LastLogonTimeStamp
foreach ($Computer in $ComputerList) {
    if ($Computer.name -and $Computer.DistinguishedName) {
        Disable-ADAccount -Identity $Computer.DistinguishedName -verbose
        Move-ADObject $Computer.DistinguishedName -TargetPath "OU=deaktiviert,OU=Computer,OU=ADO,DC=domado,DC=local" -verbose
    } else {
        Write-Host "Skipping object: Missing Name or DistinguishedName"
    }
}
