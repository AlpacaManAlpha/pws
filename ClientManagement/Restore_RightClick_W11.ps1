# Restore traditional right-click menu for Windows 11

# Add a registry key in the specified location
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

# Restart the explorer process
Stop-Process -Name explorer -Force
Start-Process explorer
