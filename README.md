# Powershell
Powershell scripts


AD_DisplayNames.ps1
  Queries the AD for first and last name. Sets the user's displayname and renames their AD object to match.
  Makes Displaynames in AD consistent. WARNING: AFFECTS ALL USERS

Remove_Old_Profiles.ps1
  Removes user profiles of anyone who hasnt logged in in over 1 year.
  Follows up with a GPUpdate and restart.
  
Report_Snippets.ps1
  Returns information about your domain
  Currrently reports:
    Age of MDT images
    Error logs on servers
    Domain expiration date
    Domain GPReport
    
  SetMail.ps1
    Takes a users username and appends a string ("@abc.co.uk") then updates the user's email fied in AD.
    
  Year7_Intake_Creation.ps1
    Turns the horrible task of making user accounts in september into a 10 minute task.
    Just get a csv from admissions, juggle the columns to match, and press go.
    You'll have to set various fields like AD OUs and paths to home directories etc.
