<# 
Overview:  This script pings the IP address in a subnet, and if it is online and does not have a DHCP address, puts it to a CSV.  See ticket # 16058

Requirements: Domain Admin; Remote Signed Execution Policy

Author: John Auerswald 4/6/2016

#>

## Start of Log File
        $Exe_User = [Environment]::UserName 
        $exe_hostname = [Environment]::Machinename
        $time = get-date -Format yyyy/MM/dd_hh:mm:ss
        $exe_script = $MyInvocation.MyCommand.name
        $exe_output = "\\skynet\scripts\script_execution_log.txt"

        $log_string = $Exe_script + "," + $exe_user + "," + $exe_hostname + "," + $time 
        write-output  "$log_string" >> $exe_output
## End of Log File


$date = get-date -Format yyyy-MM-dd
Write-Output $date
$IPprefix = "192.168."
$subnets = (1..25) ## Subnet to be seached.
Write-Output $subnets
$base_ip = "192.168.54" ## Subnet to be seached.
$range_ips = (1..255)  ## The range of IPs
$folder = "\\skynet\test_connection\check_DHCP\$date"  ## Output folder


$filter = 'IPenabled = "True" AND  DHCPenabled = "False"'   ## Finds network adapters that have IP addresses and not on DHCP.  

mkdir $folder


foreach($subnet in $subnets)
{ ## Start of $Subnets "For Each"


$base_ip = $IPprefix + $subnet + "."
Write-Output $base_ip ## Used in debugging / showing progress
$range_ips = (1..255)  ## The range of IPs

$Output_online = "$folder\online_$subnet.txt"  ## Text file of online servers.
$Output_offline = "$folder\offline_$subnet.txt"  ## Text file of servers that were offline or unable to respond to test-connection.
$output_statics = "$folder\static_IP_$subnet.csv" ## CSV of servers that were pingable and ran get-wmiobject 

    foreach($range_ip in $range_ips) 
    {  ## Start of Foreach
    $ipv4 =  "$base_IP" + "$range_ip" ## Adds the base and IP range together with a "." in the middle.  

    $online? = Test-Connection $ipv4 -Count 1 -Quiet ## Sees if the server is online and returns a true/false boolean value.


        If($Online? -eq "True")
            { ## Start of $Online "If Then"
            write-host "$ipv4 is online"
            $csv = Get-WmiObject -computername $ipv4 -Class win32_networkAdapterconfiguration -Filter $filter  | sort  dhcpenabled -Descending | select pscomputername, dhcpenabled, @{Name=’ipAddress';Expression={[string]::join(“,”, ($_.ipAddress))}}  | export-csv -Path $output_statics -Append 
        
            $ipv4 >> $Output_online
            } ## End of $Online "If Then"
    
        Else
            { ## Start of "Else"
            write-host "$ipv4 is offline"
            $ipv4 >> $Output_offline
            } ## End of "Else"

    }  ## End of "For Each" loop
} ## End of $Subnets "For Each"
