powershell.exe C:\Users\$env:USERNAME\Desktop\scripts\start-sleep.ps1
$cluster = Read-Host -Prompt "Which Cluster Are You Deploying For?"
$hosts = Import-Csv -Path C:\Users\$env:USERNAME\Desktop\scripts\cluster05.csv
$features = @()
$servers =@()
$servers=$hosts.managementip
$hosts | select hostname, managementip|Format-Table
Start-Sleep -Seconds 2
$acceptance = Read-Host -Prompt "Do you Agree to Continue (Only yes/no)" 
if($acceptance -eq 'yes')
    {
    $cred = Get-Credential
    $filepath = "C:\Users\$env:USERNAME\Desktop\scripts\adapter.csv"
    foreach ($server in $servers) {
    $Session = New-PSSession -ComputerName $server -Credential $cred
    $path = "C:\Users\$env:USERNAME\desktop\scripts\cp054856.exe"
    Copy-Item -Path $path -ToSession $Session -Destination c:\
    }   
    $data = Invoke-Command ($servers) -Credential $cred -ScriptBlock{Start-Process -FilePath "C:\cp054856.exe" -Argument "/silent" -PassThru -Wait} 
    echo $data #'Jumping to next server'
    $data | Out-File -FilePath C:\Users\$env:USERNAME\Desktop\scripts\networkdriverinstall.log -Append



########### VALIDATION ###################
Echo "Initiating Validation Module" -Verbose
Echo "Waiting for Servers to be up"
Start-Sleep -Seconds 30 -Verbose
$finalendttime = Get-Date -Format ddMMyy-HHmmss
$networkdriver=Invoke-Command ($servers) -Credential $cred -ScriptBlock{Get-NetAdapter | Where-Object status -eq 'up'| select SystemName, Name, Driverprovider }
echo $networkdriver | Where-Object Driverprovider -EQ 'Mellanox Technologies Ltd.'|  Format-Table
$networkdriver | Export-Csv -Path "C:\Users\$env:USERNAME\Desktop\scripts\Output\$cluster(NetworkDrivers)-$finalendttime.csv" -Append -NoTypeInformation

}

else {Write-Host "You Didn't Agreed"}