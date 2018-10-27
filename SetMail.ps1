### Remove the Hash symbol on lines 6 and 7 to set the email field. Leave it in place to see a list of users with NO DATA in their email field. ###

Get-ADUser -filter * -Properties * -SearchBase "OU=Users, OU=SITE, OU=Establishments, DC=SITE, DC=2LD, DC=TLD" | ? {$_.EmailAddress -eq $null} | Select-Object sAMAccountName |
ForEach-Object{
$mail = $_.sAMAccountName + "@SITE.org.uk"
#Set-ADUser -Identity $_.sAMAccountName -EmailAddress $mail
#Write-Host "Set email for $user to $mail"
}