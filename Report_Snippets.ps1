$date = Get-Date -Format dd-MM-yy
$oneMonth = (Get-Date -Format dd-MM-yy).AddMonths(-1)
$path = "C:\Automated Log Reports"


function imageCheck($imagePath){
    $images = Get-ChildItem $imagePath
    foreach($image in $images){
        $imageName = $image.Name
        if($image.CreationTime -gt (Get-Date 01/06)){
            $days = ($image.CreationTime - (Get-Date 01/06)).Days
            if(!(Test-Path "$path\$date\OldImages.txt")){New-Item -Path "$path\$date" -Name OldImage.txt -ItemType File}else{}
            Write-Host "$imageName is $days days too old, and needs to be refreshed." | Out-File -FilePath "$path\$date\OldImages.txt" -Append
        }
    }
}


function eventLogCheck($path){
    $servers = Get-ADComputer -Filter * -SearchBase "OU=Member Servers, OU=SITE, DC=SITE, DC=Internal"
    $servers += Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers, DC=SITE, DC=Internal"
    if(!(Test-Path "$path\$date")){New-Item -ItemType Directory -Path "$path\$date"}else{}
    $eventLogs = Get-EventLog -LogName *
    foreach($log in $eventLogs){
        [string]$logName = $log.LogDisplayName
        try{
            $events = Get-WinEvent -FilterHashTable @{logname=$logName; Level=1;} -ErrorAction Stop | Format-Table -Wrap
            if($events -ne ""){
                if(!(Test-Path "$path\$date")){New-Item -ItemType Directory -Path "$path\$date"}else{}
                    $events | Out-File "$path\$date\$logName.txt"
                    }
        }
        catch{
            Write-Host "No event found for $logName"
            }
    }
}

function checkDomainExpiry($domain){
$response = Invoke-WebRequest "https://who.is/whois/$domain"
[string]$domainExpires = ($response.ParsedHtml.getElementsByTagName("div") | Where{$_.className -eq 'col-md-8 queryResponseBodyValue'}).innerText
Write-Host $domainExpires.Replace(" ","")
}

function GPreport($path){
    Get-GPOReport -All -Domain SIT.Internal -Server DC_HOSTNAME -ReportType HTML -Path "C:\Automated Log Reports\$date\GPOReport.html"
    }


imageCheck("C:\Users\Charlie\Desktop")
eventLogCheck("C:\Automatic Log Reports")
checkDomainExpiry("google.co.uk")
GPReport("C:\Automatic Log Reports")