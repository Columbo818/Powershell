if (!
    # Get Current User
    (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()
    # Are they admin?
    )).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
) {
    # Reload script and run as admin
    Start-Process `
        -FilePath 'powershell' `
        -ArgumentList (
            # Flatten to single array
            '-File', $MyInvocation.MyCommand.Source, $args `
            | %{ $_ }
        ) `
        -Verb RunAs
    exit
}

$wshell = New-Object -ComObject Wscript.Shell

Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name DisableWindowsUpdateAccess -Value 0 -Force
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name DoNotConnectToWindowsUpdateInternetLocations -Value 0 -Force
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name DisableDualScan -Value 0 -Force
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name WUServer -Value 0 -Force
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name WUStatusServer -Value 0 -Force
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -Value 0 -Force
Restart-Service -Name wuauserv -Force

usoclient startinteractivescan
Start-Process ms-settings:windowsupdate

$wshell.Popup("Allow all of these updates to download & install, then restart your PC when promted. After the restart, printing will work as normal.")

New-Item -Path C:\ -ItemType File -Name PrintFix.txt -Value "1" -Force