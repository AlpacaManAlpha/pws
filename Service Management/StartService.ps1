# Check all Services set to Automatic and start them

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Get all services set to Automatic
$services = Get-WmiObject -Class Win32_Service | Where-Object { $_.StartMode -eq "Auto" }

$startedServices = @()
$failedServices = @()

foreach ($service in $services) {
    $ServiceName = $service.Name
    Write-Output "Checking service: $ServiceName"
    
    # Get the service status
    $serviceStatus = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    if ($serviceStatus) {
        # Check if the service is running
        if ($serviceStatus.Status -ne "Running") {
            Write-Output "Service '$ServiceName' is not running. Starting it now..."
            try {
                Start-Service -Name $ServiceName -ErrorAction Stop
                $startedServices += $ServiceName
            } catch {
                Write-Output "Failed to start service '$ServiceName'."
                $failedServices += $ServiceName
            }
        } else {
            Write-Output "Service '$ServiceName' is already running."
        }
    } else {
        Write-Output "Service '$ServiceName' not found."
    }
}

# Output summary
Write-Output "\nSummary:"
Write-Output "Services started: $($startedServices -join ", ")"
Write-Output "Services failed to start: $($failedServices -join ", ")"
