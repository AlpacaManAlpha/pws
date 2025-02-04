# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Discover the domain dynamically
$Domain = Get-ADDomain
$DomainDN = $Domain.DistinguishedName

# Define the number of days of inactivity
$DaysInactive = 60
$time = (Get-Date).AddDays(-($DaysInactive))

# Get a list of computers that meet the filter criteria
$ComputerList = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and OperatingSystem -notlike "*server*"} -Properties LastLogonTimeStamp, OperatingSystem, DistinguishedName

# Output the list of computers for verification
Write-Host "Found the following computers for processing:" -ForegroundColor Green
$ComputerList | Format-Table Name, DistinguishedName, LastLogonTimeStamp

# Define the target OU path dynamically
$TargetOU = "OU=Deactivated Devices,$DomainDN"

# Check if the target OU exists, create it if it doesn't
if (-not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $TargetOU } -ErrorAction SilentlyContinue)) {
    try {
        $ParentOU = "$DomainDN"
        New-ADOrganizationalUnit -Name "Deactivated Devices" -Path $ParentOU -Verbose
        Write-Host "Target OU 'Deactivated Devices' created successfully." -ForegroundColor Yellow
    } catch {
        Write-Host "Failed to create the target OU. Details: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
}

# Loop through each computer in the list
foreach ($Computer in $ComputerList) {
    # Check if the required properties exist
    if ($Computer.DistinguishedName) {
        try {
            # Disable the AD account using DistinguishedName as the identity
            Disable-ADAccount -Identity $Computer.DistinguishedName -Verbose
            Write-Host "Successfully disabled account for: $($Computer.Name)" -ForegroundColor Yellow

            # Move the computer object to the dynamically created target OU
            Move-ADObject -Identity $Computer.DistinguishedName -TargetPath $TargetOU -Verbose
            Write-Host "Successfully moved: $($Computer.Name) to the target OU" -ForegroundColor Yellow
        } catch {
            # Handle errors for each operation
            Write-Host "Error processing computer: $($Computer.Name). Details: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        # Log and skip computers with missing DistinguishedName
        Write-Host "Skipping object: Missing DistinguishedName for $($Computer.Name)" -ForegroundColor Red
    }
}

Write-Host "Script execution completed!" -ForegroundColor Green
