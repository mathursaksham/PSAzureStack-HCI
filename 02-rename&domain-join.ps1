powershell.exe C:\Users\$env:USERNAME\Desktop\scripts\start-sleep.ps1
$cluster = Read-Host -Prompt "Which Cluster Are You Deploying For?"
$starttime = Get-Date -Format ddMMyy-HHmmss
Add-Content -Path "C:\Users\$env:USERNAME\Desktop\scripts\dns-rename-domain.log" -Value "$starttime | Rename_DomainJoin_DNS Script Started"
$hosts = $null
$hosts = Import-Csv -Path C:\Users\$env:USERNAME\Desktop\scripts\cluster05.csv
$hosts | select hostname, managementip|Format-Table
$servers =@()
$servers=$hosts.managementip
Start-Sleep -Seconds 2
$acceptance = Read-Host -Prompt "Do you Agree to Continue (Only yes/no)" 
if($acceptance -eq 'yes')
{
    $cred = Get-Credential -Message "Administrator Credentials" -UserName 'Administrator'
    $cred1 = Get-Credential -Message "Domain Administrator Credentials" -UserName 'pltf\Administrator'
    $dns1 = '10.212.32.12'
    $dns2 = ''
    $data = $null
    $logfilepath = "C:\Users\$env:USERNAME\Desktop\scripts\dns-rename-domain.log"
    foreach($ip in $hosts){

    $newname = $ip.Hostname
    $managementip=$ip.managementip

    $session = New-PSSession -ComputerName $managementip -Credential $cred1 -Name 'session'
    $Sessionstarttime = Get-Date -Format ddMMyy-HHmmss
    if ($session){Add-Content -Path $logfilepath -Value "$Sessionstarttime | Session connected on $managementip"}else{Add-Content -Path $logfilepath -Value "$Sessionstarttime | Session Failed on $managementip"}
    $data = Invoke-Command -Session $session  -ScriptBlock{
    Set-DnsClientServerAddress -InterfaceAlias 'Management' -ServerAddresses ("$using:dns1","$using:dns2")
    Add-Computer -DomainName 'pltf.meghraj.in' -DomainCredential $using:cred1 -NewName $using:newname -Restart -Force -LocalCredential $using:cred
    }
    $scriptendtime = Get-Date -Format ddMMyy-HHmmss
    if ($data.lenghth -gt 0) {$data = $data} else{$data = $ip.hostname+" "+$managementip+" "+"failed to modify"}
    Add-Content -Path $logfilepath -Value "$scriptendtime $data"
    }

    $finalendttime = Get-Date -Format ddMMyy-HHmmss
    Add-Content -Path "C:\Users\$env:USERNAME\Desktop\scripts\dns-rename-domain.log" -Value "$finalendttime | Rename_DomainJoin_DNS Script completed"

    ########### VALIDATION ###################
Echo "Initiating Validation Module" -Verbose
Echo "Waiting for Servers to be up"
Start-Sleep -Seconds 360 -Verbose
$hostname=Invoke-Command ($servers) -Credential $cred -ScriptBlock{[System.Net.Dns]::GetHostByName($env:computerName) }
echo $hostname | select Hostname, Addresslist |Format-Table
$hostname | Export-Csv -Path "C:\Users\$env:USERNAME\Desktop\scripts\Output\$cluster(Domainjoin)-$finalendttime.csv" -Append -NoTypeInformation
}
else
{
Write-Output "You Didn't Agreed"
}
