Import-Module ActiveDirectory # For queries and password resets

# These four fields configure the script.
$smtpRelay = "servername.contoso.com" #DNS name or IP of on-site SMTP relay
$fromAddr = "SSPR@contoso.com" # Address the email should appear to be from
$recipients = @( # List of recipients (comma separated)
"compsci@contoso.com",
"admin@contoso.com"
)
$AD_Query = "Office" # The field in AD that should be queried for card number. I typically use the Office field.

#Store C# signature of BlockInput method into $signature variable
$signature = @"
  [DllImport("user32.dll")]
  public static extern bool BlockInput(bool fBlockIt);
"@

$block = Add-Type -MemberDefinition $signature -Name DisableInput -Namespace DisableInput -PassThru

$qualities = @("able", "acid", "angry", "automatic", "beautiful", "black", "boiling", "bright",`
 "broken", "brown", "cheap", "chemical", "chief", "clean", "clear", "common", "complex", "conscious",`
 "cut", "deep", "dependent", "early", "elastic", "electric", "equal", "fat", "fertile", "first", "fixed",`
 "flat", "free", "frequent", "full", "general", "good", "great", "grey", "hanging", "happy", "hard", "healthy",`
 "high", "hollow", "important", "kind", "like", "living", "long", "married", "material", "medical", "military",`
 "natural", "necessary", "new", "normal", "open", "parallel", "past", "physical", "political", "poor", "possible",`
 "present", "private", "probable", "presentable", "quick", "quiet", "ready", "red", "regular", "responsible", "right",`
  "round", "same", "second", "separate", "serious", "sharp", "smooth", "sticky", "stiff", "straight", "strong", "sudden",`
  "sweet", "tall", "thick", "tight", "tired", "true", "violent", "waiting", "warm", "wet", "wide", "wise", "yellow", "young") # Get list of Adjectives for generating passwords

$animals = @("alligator", "ant", "bear", "bee", "bird", "camel", "cat", "cheetah", "chicken", "chimpanzee", "cow", "crocodile",`
"deer", "dog", "dolphin", "duck", "eagle", "elephant", "fish", "fly", "fox", "frog", "giraffe", "goat", "goldfish", "hamster",`
 "hippopotamus", "horse", "kangaroo", "kitten", "lion", "lobster", "monkey", "octopus", "owl", "panda", "pig", "puppy", "rabbit",`
  "rat", "scorpion", "seal", "shark", "sheep", "snail", "snake", "spider", "squirrel", "tiger", "turtle", "wolf", "zebra") #list of Animals for generating passwords

$TI = (Get-Culture).TextInfo # Only needed for access to ToTitleCase() method

While($true){
Write-Host "<Org Name> Self-Service Password Reset"
[string]$cardID = Read-Host -Prompt "Please touch your ID card to the reader"
$block::BlockInput($true) | Out-Null
$cardID = $cardID.Substring(2,8)
Try{
    $user = Get-ADuser -Properties * -Filter {$AD_Query -eq $cardID}
    if($user -ne $null){
    $userName = $user.SamAccountName
    $fullName = $user.displayName
    $pass = $TI.ToTitleCase((Get-Random $qualities)) + $TI.ToTitleCase((Get-Random $animals)) + (Get-Random -Maximum 99)
    $subject = "[SSPR]Account details for $fullName"
    $body = "The password for $fullname has been set to $pass `nTheir username is $userName `n`n`nThis is an automated messge - please do not reply.`nPlease contact IT support with any queries."
    $pass = $pass | ConvertTo-SecureString -AsPlainText -Force
    Set-ADAccountPassword -Identity $userName -NewPassword $pass
    Send-MailMessage -From $fromAddr -To $recipients -Subject $subject -SmtpServer $smtpRelay -Body $body
    Write-Host "Password has been reset. Please see your Computer Science teacher."
    Start-Sleep(3)
    }
}
Catch{
    Write-Host "Unable to match user account. Please contact IT Support"
    Start-Sleep(2)
    }
finally{$block::BlockInput($false) | Out-Null}
Clear-Host
$user = $null
$userName = $null
$fullName = $null
$cardID = $null
$pass = $null
}
