powershell.exe C:\Users\$env:USERNAME\Desktop\scripts\start-sleep.ps1
$hosts = $null
$hosts = Import-Csv -Path C:\Users\$env:USERNAME\Desktop\scripts\cluster05.csv
$hosts | select hostname, managementip|Format-Table
Start-Sleep -Seconds 2
$servers = $null
$acceptance = Read-Host -Prompt "Do you Agree to Continue (Only yes/no)" 
if($acceptance -eq 'yes')
    {
    $cred = Get-Credential -UserName 'Administrator' -Message "Local Credentials"
    $filepath = "C:\Users\$env:username\Desktop\scripts\adaptersettings.log"
    $newname = $ip.Hostname
    $servers =@()
    $servers=$hosts.managementip
    #foreach($ip in $hosts){
    $starttime = Get-Date -Format ddMMyy-HHmmss
    $newname = $ip.Hostname
    $computevlan
    $storage1vlan=$ip.storage1vlan
    $storage2vlan=$ip.storage2vlan 
    #$session = New-PSSession -ComputerName $ip.managementip -Credential $cred -Name 'session'
    #if ($session){Add-Content Path $filepath -Value "$Sessionstarttime | Session connected on $newname"}else{Add-Content -Path $filepath -Value "$Sessionstarttime | Session Failed on $newname"}
    $data = Invoke-Command ($servers) -Credential $cred -ScriptBlock{
    Rename-NetAdapter -Name 'PCIe Slot 3 port 1' -NewName 'Management'
    Rename-NetAdapter -Name 'PCIe Slot 4 port 1' -NewName 'Compute'
    Rename-NetAdapter -Name 'PCIe Slot 3 port 2' -NewName 'Storage1'
    Rename-NetAdapter -Name 'PCIe Slot 4 port 2' -NewName 'Storage2'
    #Set-NetAdapter -Name 'Compute' -VlanID $using:computevlan
    Set-NetAdapter -Name 'Storage1' -VlanID $using:Storage1vlan -AsJob
    Set-NetAdapter -Name 'Storage2' -VlanID $using:Storage2vlan -AsJob
 
    Set-NetAdapterAdvancedProperty -Name “Management” -RegistryKeyword “*JumboPacket” -Registryvalue 9000
    Set-NetAdapterAdvancedProperty -Name “Compute” -RegistryKeyword “*JumboPacket” -Registryvalue 9000
    Set-NetAdapterAdvancedProperty -Name “Storage1” -RegistryKeyword “*JumboPacket” -Registryvalue 9000
    Set-NetAdapterAdvancedProperty -Name “Storage2” -RegistryKeyword “*JumboPacket” -Registryvalue 9000
    Set-NetAdapterRdma -Enabled:$true
    }
    $scriptendtime = Get-Date -Format ddMMyy-HHmmss
    if ($data.lenghth -gt 0) {$data = $data} else{$data = $newname+" "+$managementip+" "+"failed to modify"}
    Add-Content -Path $filepath -Value "$scriptendtime $data"
    #}

}
else {Write-Host "You Didn't Agreed"}