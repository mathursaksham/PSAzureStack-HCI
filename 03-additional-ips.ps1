powershell.exe C:\Users\$env:USERNAME\Desktop\scripts\start-sleep.ps1
$hosts = Import-Csv -Path C:\Users\$env:USERNAME\desktop\scripts\cluster05.csv
$hosts | select hostname, managementip|Format-Table
Start-Sleep -Seconds 2
$acceptance = Read-Host -Prompt "Do you Agree to Continue (Only yes/no)" 
if($acceptance -eq 'yes')
{
    $cred = Get-Credential
    foreach($ip in $hosts){
    $newname = $ip.Hostname
    $storage1ip=$ip.storage1ip
    $storage2ip=$ip.storage2ip
    $storage1vlan=$ip.storage1vlan
    $storage2vlan=$ip.storage2vlan

    $prefixlenght2=$ip.prefixlenght2
    $prefixlenght1=$ip.prefixlenght1
    $computeip = $ip.computeip
    $prefixlenghtcompute =$ip.prefixlenghtcompute

    $defaultgateway1=$ip.defaultgateway1
    $defaultgateway2=$ip.defaultgateway2
    $computedefaultgateway= $ip.computedefaultgateway

    $session = New-PSSession -ComputerName $ip.managementip -Credential $cred -Name 'session'

    $data = Invoke-Command -Session $session  -ScriptBlock{
    
    New-NetIPAddress -InterfaceAlias 'Storage1' -IPAddress $using:storage1ip -PrefixLength $using:prefixlenght1
    Set-NetAdapter -InterfaceAlias 'Storage1' -VlanID $using:storage1vlan -Asjob
    New-NetIPAddress -InterfaceAlias 'Storage2' -IPAddress $using:storage2ip -PrefixLength $using:prefixlenght2
    Set-NetAdapter -InterfaceAlias 'Storage2' -VlanID $using:storage2vlan -AsJob
    #New-NetIPAddress -InterfaceAlias 'Compute' -IPAddress $using:computeip -PrefixLength $using:prefixlenghtcompute

    }

    echo 'Jumping to next server'
    $data | Out-File -FilePath C:\Users\Administrator\Desktop\Saksham\scripts\IPs-addition.log -Append
    }
}
else {Write-Host "You Didn't Agreed"}
#10.212.42.42 27 10.212.33.1