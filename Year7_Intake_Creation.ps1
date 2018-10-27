###################################################
# Need help? Start reading here.
# This script makes user accounts for students.
# It requires a CSV exported from SIMS. Name is not important, but the CSV must be the one output by the "SIMS.net to library V2" report.
# It attempts to clean up usernames, but in case of strange behaviour here's an outline:
# Removes special characters like apostrophes and hyphens.
# Capitalises Initial and first letter in Surname, sends rest to lowercase.
# Caps usernames at 15 characters (May cause strange usernames, but avoids NetBIOS errors)
###################################################

$csvPATH = "C:\Path\to\CSV\students.csv" # Allows for custom csv location

function CreateFolder ([string]$Path) {

	# Check if the folder Exists

	if (Test-Path $Path) {
		Write-Host "Folder: $Path Already Exists" -ForeGroundColor Yellow
	} else {
		Write-Host "Creating $Path" -Foregroundcolor Green
		New-Item -Path $Path -type directory | Out-Null
	}
}

function SetAcl ([string]$Path, [string]$Access, [string]$Permission) {

	# Get ACL on FOlder

	$GetACL = Get-Acl $Path

	# Set up AccessRule

	$Allinherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$Allpropagation = [system.security.accesscontrol.PropagationFlags]"None"
	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule($Access, $Permission, $AllInherit, $Allpropagation, "Allow")

	# Check if Access Already Exists

	if ($GetACL.Access | Where { $_.IdentityReference -eq $Access}) {

		Write-Host "Modifying Permissions For: $Access" -ForeGroundColor Yellow

		$AccessModification = New-Object system.security.AccessControl.AccessControlModification
		$AccessModification.value__ = 2
		$Modification = $False
		$GetACL.ModifyAccessRule($AccessModification, $AccessRule, [ref]$Modification) | Out-Null
	} else {

		Write-Host "Adding Permission: $Permission For: $Access"

		$GetACL.AddAccessRule($AccessRule)
	}

	Set-Acl -aclobject $GetACL -Path $Path

	Write-Host "Permission: $Permission Set For: $Access" -ForeGroundColor Green
}

function cleanString([string]$string){
    $string = $string.Substring(0,1).ToUpper() + $string.Substring(1,$string.Length-1).ToLower()
    $string = $string -replace " ",""
    $string = $string -replace "'",""
    $string = $string -replace "-",""
    return $string
    }

$location = Get-Location
$output = "$location\output.csv" # Locally stores the output CSV for emailing
$csv = Get-ChildItem $location\*.csv
if($csv){"Found CSV. Attempting import.";$csvPATH = $csv}else{"No CSV Detected. Please ensure SIMS exported CSV is present.";break}
[string]$yearNow = (Get-Date).Year
$yearNow = $yearNow.Substring(2,2)
[string]$monthNow = (Get-Date).Month
if($monthNow -lt 9){$yearNow = $yearNow-1}

Import-Csv $csvPATH | ForEach-Object{
    If(($_.Admission -ne "")){
        $year = $_.Year
        switch($year){
        "Year 7"{[string]$intake=$yearNow}
        "Year 8"{[string]$intake=$yearNow-1}
        "Year 9"{[string]$intake=$yearNow-2}
        "Year 10"{[string]$intake=$yearNow-3}
        "Year 11"{[string]$intake=$yearNow-4}
        "Year 12"{[string]$intake=$yearNow-5}
        "Year 13"{[string]$intake=$yearNow-6}
        }
        $descYear = "Intake20" + $intake
        $firstName = $_.Forename
        $cleanFirst = cleanString($firstName)
        $firstName = $firstName.Substring(0,1).ToUpper() + $firstName.Substring(1,$firstName.Length-1)
        $firstName = $firstName -replace " ",""
        $firstName = $firstName -replace "'",""
        $firstName = $firstName -replace "-",""
        $lastName = $_.Surname
        $cleanLast = cleanString($lastName)
        $lastName = $lastName.Substring(0,1).ToUpper() + $lastName.Substring(1,$lastName.Length-1)
        $lastName = $lastName -replace " ",""
        $lastName = $lastName -replace "'",""
        $lastName = $lastName -replace "-",""
        #if($lastName.Substring($lastName.Length - 1) -eq " "){$lastName = $lastName.Remove($lastName.Length-1)}
        $user = $intake + $cleanFirst.substring(0,1) + "." + $cleanLast
        $dispName = $firstName + " " + $lastName
        if($user.Length -gt 15){$user = $user.Substring(0,15)}
        Write-host $user
        Write-Host $dispName
        Write-Host "----------"
        $path = "OU=$descYear,OU=Students,OU=Synced Users,OU=Users,OU=SITE,OU=Establishments,DC=domain,DC=SITE,DC=org,DC=uk"
        #$profilepath = "\\SITE-FS001\TeachingStaffProfiles$\$user" #No longer using roaming profiles. Remove the "#" at the start of the line to re-enable.
        $homedir = "\\SITE-FS001\$user$"
        $dnsroot  = (Get-ADDomain).DNSRoot
        $setpass = ConvertTo-SecureString -AsPlainText "Intrepidu5" -force
        $mail = $user + "@SITE.org.uk"
        $checkuser = $(try {Get-ADUser $user} catch {$null})
        $stf = $_.Adno
        If($checkuser -ne $null){"User $user already exists"}
        # If it doesnt, create it!
        Else{        
        # Spit out the username to console
        Write-Host "Creating $user"
        # Create the user with the following AD fields supplied as arguments. Split across lines for ease of reading.
        New-ADUser $user `
        -Path $path `
        -GivenName $firstName `
        -Surname $lastName `
        -DisplayName ($dispName) `
        -Description "$descYear" `
        -UserPrincipalName ($user + "@" + $dnsroot) `
        -AccountPassword $setpass `
        -homeDirectory $homedir `
        -homeDrive N: `
        -Enabled $true `
        -PasswordNeverExpires $False `
        -EmailAddress $mail `
        -ChangePasswordAtLogon $true `
        -Office $stf
        #-profilePath $profilepath #No longer using roaming profiles. Remove the "#" at the start of the line to re-enable.
        # Add user to necessary groups. Outside of the If statement now, but still inside the ForEach loop.
        #Add-ADGroupMember -identity 'CN=SITE Sixthform User,OU=Student Users,OU=User Groups,OU=Groups,OU=SITE,OU=Establishments,DC=domain,DC=SITE,DC=org,DC=uk' $user
        Add-ADGroupMember -identity 'CN=SITE Student User Type,OU=Student Users,OU=User Groups,OU=Groups,OU=SITE,OU=Establishments,DC=domain,DC=SITE,DC=org,DC=uk' $user
        Add-ADGroupMember -identity 'CN=SITE Student Users,OU=Student Users,OU=User Groups,OU=Groups,OU=SITE,OU=Establishments,DC=domain,DC=SITE,DC=org,DC=uk' $user
        Add-ADGroupMember -identity 'CN=SITE File Server 1,OU=General,OU=Groups,OU=SITE,OU=Establishments,DC=domain,DC=SITE,DC=org,DC=uk' $user
        Add-ADGroupMember -Identity 'CN=SITE_Students_Internet_Smoothwall,OU=Internet Access,OU=User Groups,OU=Groups,OU=SITE,OU=Establishments,DC=domain,DC=SITE,DC=org,DC=uk' $user
        Add-ADGroupMember -identity "CN=$descYear,OU=Synced Groups,OU=Resource Access Groups,OU=User Groups,OU=Groups,OU=SITE,OU=Establishments,DC=domain,DC=SITE,DC=org,DC=uk" $user
        Enable-ADAccount -identity $user
        #}
        # Output and log success
        Write-Host "Made $user" -ForegroundColor Green
        }
        If(!(Test-Path "\\SITE-FS001\$user$")){
        $Path = "H:\Users\Students\Data\$descYear\$user"
        $Access = "domain\$user"
        $Permission = "WriteAttributes,ReadAttributes,Traverse, DeleteSubdirectoriesAndFiles,Delete,ListDirectory,WriteExtendedAttributes,ReadExtendedAttributes,CreateFiles,CreateDirectories, ReadPermissions"
	    CreateFolder $Path 
	    SetAcl $Path $Access $Permission
        $name = "$user$"
        # Create a Server message block share, granting the user full access
        New-SmbShare –Name $name –Path "H:\Users\Students\Data\$descYear\$user" –FullAccess $user
        # Set SMB permissions for the user and administrators. Revoke permissions that would allow any user to view it from explorer
        Grant-SmbShareAccess -Name "$name" -AccountName "domain\$user" -AccessRight Full  -ErrorAction SilentlyContinue -Force
        Grant-SmbShareAccess -Name "$name" -AccountName "domain\Administrator" -AccessRight Full -Force
        Revoke-SmbShareAccess -Name $name -AccountName "Everyone" -Force
        # Output and log folder creation success
        Write-Host "Made home folder for $user" -ForegroundColor Green
        }
        Else{
        # Log the existence of a folder, and continue
        Write-host "$user already has a home folder"
        }
        }
        New-Object -TypeName PSCustomObject -Property @{
        FirstName = $firstName
        LastName = $lastName
        UserName = $user
        Email = "$user@SITE.org.uk"
        Password = "Intrepidu5"
        Admission = $office
        Year = $year
        } | Select-Object FirstName, LastName, UserName, Email, Admission, Year | Export-Csv -Path $output -NoTypeInformation -Append
        }

$recipients = @(
"user1@SITE.org.uk",
"user2@SITE.org.uk"
)
Send-MailMessage -From "alerts@SITE.org.uk" -To $recipients -Subject "New student users ready" -Attachments $output -SmtpServer SITE-Web001 -Body "This is an Automated email. Please do not respond. Any queries should be directed to it@support.SITE.org.uk"
Remove-Item $csvPATH -Force