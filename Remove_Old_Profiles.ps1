Get-WMIObject -class Win32_UserProfile | Where {$_.LastuseTime -gt (Get-Date).AddYears(-1)} | Remove-WmiObject
gpupdate.exe
Restart-Computer "localhost"