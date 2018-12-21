[string]$psPath = Split-Path -parent $PSCommandPath
[string]$date = (Get-Date -Format dd.MM.yy)
[string]$fileName = "Shares_$date.csv"
$shares = Get-WmiObject win32_Share
foreach($share in $shares){
    $name = $share.Name
    $path = $share.Path
    try{
    $ACL = Get-Acl $path
    foreach($entry in $ACL.Access){
        $object = [PSCustomObject]@{   
            Drive = [string]$path.Substring(0,2)
            Name = [string]$name
            User = [string]$entry.IdentityReference
            Access = [string]$entry.FileSystemRights
            Rights = [string]$entry.AccessControlType
            } | Export-Csv "$psPath\$fileName" -Append -Force -NoTypeInformation
        }
    }
    catch{
    Write-Host "$name has no ACL, and is therefore not actually a used share"
    }
}