$cluster = Read-Host -Prompt "Which Cluster Are You Deploying For?"
powershell.exe C:\Users\$env:USERNAME\Desktop\scripts\start-sleep.ps1
$hosts = Import-Csv -Path C:\Users\$env:USERNAME\Desktop\scripts\cluster05.csv
$hosts | select hostname, managementip|Format-Table
$servers =@()
$servers=$hosts.managementip
Start-Sleep -Seconds 2
$acceptance = Read-Host -Prompt "Do you Agree to Continue (Only yes/no)" 
if($acceptance -eq 'yes')
{ 

    $cred = Get-Credential -UserName "pltf\administrator" -Message "Domain Credentials"
    $managementvlan = Read-Host -Prompt "Please share the VLAN ID to be attached to Management Intent"
    $storagevlan1 = Read-Host -Prompt "Please share the VLAN ID to be attached to Storage1 Intent"
    $storagevlan2 = Read-Host -Prompt "Please share the VLAN ID to be attached to Storage2 Intent"
    #foreach($ip in $hosts){
    $newname = $ip.Hostname
    #$session = New-PSSession -ComputerName $ip.managementip -Credential $cred -Name 'session'
    $data = Invoke-Command ($servers) -Credential $cred -ScriptBlock{
    $AdapterOverride = New-NetIntentAdapterPropertyOverrides
    $AdapterOverride.JumboPacket = 9000
    $StorageOverride = New-NetIntentStorageOverrides
    $StorageOverride.EnableAutomaticIPGeneration = $false
    Start-Sleep -Seconds 1
    Add-NetIntent -Name Storage -Storage -AdapterName 'Storage1', 'Storage2' -StorageOverrides $StorageOverride  -StorageVLANs "$using:storagevlan1", "$using:storagevlan2" -AdapterPropertyOverrides $AdapterOverride
    Start-Sleep -Seconds 60
    Add-NetIntent -Name "MgmtComp" -Management -Compute -AdapterName "Management", "Compute" -ManagementVlan $using:managementvlan -AdapterPropertyOverrides $AdapterOverride
    }
    echo 'Jumping to next server'
    $data | Out-File -FilePath C:\Users\$env:USERNAME\Desktop\scripts\intent-addition.log -Append
    #}


################# Validation ################
Echo "Collecting Net-Intent Data"
Start-Sleep -Seconds 120
$finalendttime = Get-Date -Format ddMMyy-HHmmss
$netintentdata = Invoke-Command ($servers) -Credential $cred -ScriptBlock{Get-NetIntentStatus | select host, intentname, provisioningstatus}
echo $netintentdata
$netintentdata | Export-Csv -Path "C:\Users\$env:USERNAME\Desktop\scripts\Output\$cluster(netintent)-$finalendttime.csv" -Append -NoTypeInformation
}




else {Write-Host "You Didn't Agreed"}




<#
$AdapterOverride = New-NetIntentAdapterPropertyOverrides
$AdapterOverride.JumboPacket = 9000
Add-NetIntent -Name "MgmtComp" -Management -Compute -AdapterName "Management", "Compute" -ManagementVlan 410 -AdapterPropertyOverrides $AdapterOverride
#>