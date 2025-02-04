# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define the number of days of inactivity
$DaysInactive = 60
$time = (Get-Date).AddDays(-($DaysInactive))

# Get a list of computers that meet the filter criteria
$ComputerList = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and OperatingSystem -notlike "*server*"} -Properties LastLogonTimeStamp, OperatingSystem, DistinguishedName

# Output the list of computers for verification
Write-Host "Found the following computers for processing:" -ForegroundColor Green
$ComputerList | Format-Table Name, DistinguishedName, LastLogonTimeStamp

# Loop through each computer in the list
foreach ($Computer in $ComputerList) {
    # Check if the required properties exist
    if ($Computer.DistinguishedName) {
        try {
            # Disable the AD account using DistinguishedName as the identity
            Disable-ADAccount -Identity $Computer.DistinguishedName -Verbose
            Write-Host "Successfully disabled account for: $($Computer.Name)" -ForegroundColor Yellow

            # Move the computer object to the specified OU
            Move-ADObject -Identity $Computer.DistinguishedName -TargetPath "OU=deaktiviert,OU=Computer,OU=ADO,DC=domado,DC=local" -Verbose
            Write-Host "Successfully moved: $($Computer.Name) to the target OU" -ForegroundColor Yellow
        }
        catch {
            # Handle errors for each operation
            Write-Host "Error processing computer: $($Computer.Name). Details: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        # Log and skip computers with missing DistinguishedName
        Write-Host "Skipping object: Missing DistinguishedName for $($Computer.Name)" -ForegroundColor Red
    }
}

Write-Host "Script execution completed!" -ForegroundColor Green
