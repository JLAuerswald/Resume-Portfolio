<# 
Overview:   This script will check each server in the server OU for patches that are installed on that day.   It will email the results to a ticket for documentation.  

Requirements:   Domain Admin, Active Directory module, Remote Signed Execution Policy.

Tested on: Windows 7 PS v5; Windows 10 PS v5;

Author: John Auerswald

Last revision: 2016-11-8

#>


Add-PSlog "SMTP_list_updates.ps1" 60  ## Adds to the log of PS scripts with a lowball figure how long it would take to perform that task manually.  

Clear-Variable emailbody ## Clears the variable since it adds to itself in the foreach loop.
Clear-Variable patches
Clear-Variable patch

$log_path = "\\skynet\logs\list_updates\"
$output_folder = Get-Date -Format "yyyy-MM-dd_hh-mm"
$full_output =  "$log_path\$output_folder"
mkdir $full_output 

$sb = "ou=servers,ou=system,DC=skynet,DC=local" ## Limits the search base to the server OU.
$date =  get-date -Format "M/dd/yyyy"  ## Date formatted to match the "installedon" field for "where-object"
$servers = Get-ADComputer -SearchBase $sb -filter 'cn -NOTLIKE "*-lnx"' | select -ExpandProperty name ## Gets all the systems that do not have "-lnx" in the name from the server OU
#$servers = "mis-bes"
$output = "$full_output\list_updates.csv" 

[string]$emailbody = "" ## Sets the variable to a string and clears it.... again.  

foreach($server in $servers) ##Performs the following in for each server in the Servers OU.
{  ## Start of $Servers Foreach Loop

$online?  = Test-Connection -Computername $server -Count 1 -quiet  ## Boolean variable to see if the system is online.
    
    If($online? -eq $true)  ## If the system is online and the firewall is off, then it will perform the "get-hotfix" cmdlet.
        
        { ## Start of $online "If" statement
        echo $server; ## Displays the name to show the progress
        $patches = get-hotfix -ComputerName $server | select-object PScomputername,description,hotfixid,installedby,installedon | Where-Object -Property installedon -contains $date  ## Gets the installed updates from each server that does not have firewall turned on.  
        } ## End of $online "If" statement

} ## End of $servers foreach loop
   
    Foreach($patch in $patches) ## Performs this for every patch on every server.  
   
   { ## Start of the $patches foreach loop.
  
    $patch | export-csv -Path $output -Append ## Exports the patch to a CSV on the network drive.
    $emailbody = $emailbody + $patch.PScomputername + "," + $patch.hotfixid + "," + $patch.installedon  + ", `r`n"   ## This is used to create an "human-readable" output that can be sent via email and put into a RT ticket for documentation.
        
   } ## End of $patches foreach loop

   


## Sends an email with the "human readable" output from $emailbody and emails it to myself and the ticketing system for documentation
Send-MailMessage -To "helpdesk@skynet.local" -Subject "[Ticket #14081] Applied Updates" -From "John Auerswald <jlauerswald@gmail.com>" -Body "The following updates where applied on $date 

$emailbody" -SmtpServer smtp.skynet.local  -Attachments $output 

