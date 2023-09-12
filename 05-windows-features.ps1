powershell.exe C:\Users\$env:username\desktop\scripts\start-sleep.ps1
$hosts = Import-Csv -Path C:\Users\$env:username\desktop\scripts\cluster05.csv
$features = @()
$servers =@()
$servers=$hosts.managementip
$features = ("BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica")
$features | Format-Table
Write-Host "#### Check For Featured to be installed ####" -ForegroundColor Cyan
Start-Sleep -Seconds 3
$hosts | select hostname, managementip|Format-Table
Start-Sleep -Seconds 2
$acceptance = Read-Host -Prompt "Do you Agree to Continue (Only yes/no)" 
if($acceptance -eq 'yes')
    {
    $cred = Get-Credential
    $filepath = "C:\Users\$env:username\desktop\scripts\adapter.csv"
    #foreach($ip in $hosts){
    $newname = $ip.Hostname
    #$session = New-PSSession -ComputerName $ip.managementip -Credential $cred -Name 'session'
    $data = Invoke-Command ($servers) -Credential $cred -ScriptBlock{
    Install-WindowsFeature -Name "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica" -IncludeAllSubFeature -IncludeManagementTools
    }
    echo 'Jumping to next server'
    $data | Out-File -FilePath C:\Users\$env:username\desktop\scripts\featuresupdate.log -Append
    #}

}
else {Write-Host "You Didn't Agreed"}