<#
.SYNOPSIS Gets the MD5 hash of the file and uses it to get the report from virus total.   Useful for when it is note convenient to upload a file to the virus total site.  

.PARAMETER $VT_File The file that will have it's MD5 hash submitted to VirusTotal.com

.EXAMPLE Get-VirusTotal c:\users\jlauerswald\downloads\file.exe 

Created: 2017-1-13
Modified: 2018-9-24
Author: John Auerswald
Email: JLAuerswald@Gmail.com
#>


function global:Get-VirusTotal_Report{
param( ## Start of setting parameter
[Parameter(Mandatory=$true,ValueFromPipeline=$True)] ## Makes the parameter mandatory and will accept it from a pipeline.
[String] $VT_File 

) ## End of parameter

Add-PSlog "Get-VirusTotal_Report.ps1" 5
    echo "The full path of the file is: $VT_File" ## Shows file fullpath.  
    $MD5 = get-filehash -path $vt_file -Algorithm md5 | select -ExpandProperty hash  ## Creates an MD5 hash of the target file.
    echo "The MD5 Hash is: $MD5"  
    $webpage = "https://www.virustotal.com/latest-scan/" + "$md5"   ## Creates a link to virus total with the MD5 attached.

    echo "The URL is $webpage" 
    start-process -filepath "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" -argumentlist "$webpage"  ## Loads the VirusTotal site with the md5 hash in question




}  ## End of function




