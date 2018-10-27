### Some Names in AD are usernames, some are display names?
### This converts them all to display names.
### Remove hashes, run it, replace the hashes for safety.


Get-ADUser -Filter * -Properties * -SearchBase "OU=SITE, OU=Establishments, DC=SITE, DC=DOMAIN, DC=2LD, DC=TLD" | Select-Object sAMAccountName, cn, Givenname, Surname |
  ForEach-Object{
  $user = $_.sAMAccountName
  $forename = $_.Givenname
  $surname = $_.Surname
  [string]$fullname = $forename + " " + $surname
    #Set-ADUser $user -DisplayName $fullname -PassThru |
    #Write-Host $user, $fullname
    #Rename-ADObject -NewName $fullname
    #Write-Host "$user Display Name and AD Name set sucessfully" -ForegroundColor Green
    }