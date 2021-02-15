
# Remove Kaseya Agent
# Stop currently running Kaseya services, set startup type to Disabled and kill processes
Try {
    Get-Service -DisplayName "Kaseya*" | Stop-Service -Force -ErrorAction Stop
} Catch {
    Write-Host "No Kaseya services needed to be stopped - services may have been stopped previously or agent no longer installed.`n$_" -BackgroundColor Black -ForegroundColor Red
}
Try {
    Get-Service -DisplayName "Kaseya*" | Set-Service -StartupType Disabled -ErrorAction Stop
} Catch {
    Write-Host "Kaseya services may already be disabled.`n$_" -BackgroundColor Black -ForegroundColor Red
}
Try {
    Get-Process "KaUsrTsk" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
} Catch {
    Write-Host "No KaUsrTsk process running, may have previously stopped, continuing..." -BackgroundColor Black -ForegroundColor Yellow
}

# Check Registry for Path - HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Kaseya\Agent
$KaseyaRegKeyPath = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Kaseya\Agent"
$KaseyaAgentName = $KaseyaRegKeyPath.PSChildName
$KaseyaExePath = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Kaseya\Agent\$KaseyaAgentName").Path

Try {
    $KaseyaExecutable = Get-Item "$($KaseyaExePath)\KASetup.exe" -ErrorAction Stop
} Catch {
    Write-Host "Could not find executable in Registry provided path - $KaseyaExePath`n$_" -BackgroundColor Black -ForegroundColor Red
}

# Folder name is also Agent Name, and required for uninstall process.
# https://helpdesk.kaseya.com/hc/en-gb/articles/229039368-Uninstall-an-Agent-Via-Command-Line

& "$($KaseyaExecutable.FullName)" /s /r /g $KaseyaAgentName /l "C:\Temp\karemoval.log"