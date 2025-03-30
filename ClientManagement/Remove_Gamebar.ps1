# Uninstall the Gamebar with the following command:
Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage

# Remove Overlay PopUp for "you'll need a new app to open this ms-gamingoverlay-link "
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR /f /t REG_DWORD /v "AppCaptureEnabled" /d 0
reg add HKEY_CURRENT_USER\System\GameConfigStore /f /t REG_DWORD /v "GameDVR_Enabled" /d 0
