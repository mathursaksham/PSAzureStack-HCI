$notepad = Start-Process -FilePath "C:\Users\$env:username\desktop\scripts\cluster.csv" -Wait

Write-Host "####################################################################################"
Write-Host "###################### Azure Stack HCI Automation ##################################" -ForegroundColor White -BackgroundColor Black
Write-Host "####################################################################################"

Write-Host "
1. Network Adapter Settings
2. Rename the server / Join Domain
3. Attach additional IPs to NICs
4. Install Mellanox Drivers
5. Install all required Windows-Features
6. Push Windows Update
7. Create Pre Cluster Intent Creation
8. Test Cluster
9.  Create Cluster
10. Cluster Level Intent Creation
11. Add Volumes - (images/platform/etc)
12. Deploy SDN 
13. Update all SDN Nodes
14. Register Cluster with Azure Arc" -ForegroundColor Cyan 

Write-Host "####################################################################################" -BackgroundColor Black -ForegroundColor White
Start-Sleep -Seconds 5

$action=Read-Host "What activity would you like to perform"

if($action -eq 1){& .\Desktop\scripts\01-netadapter-settings.ps1}
elseif($action -eq 2){& '.\Desktop\scripts\02-rename&domain-join.ps1'} 
elseif($action -eq 3){& .\Desktop\scripts\03-additional-ips.ps1}
elseif($action -eq 4){& .\Desktop\scripts\04-network-driver-install.ps1}
elseif($action -eq 5){& .\Desktop\scripts\05-windows-features.ps1}
elseif($action -eq 6){& .\Desktop\scripts\06-windows-update.ps1}
elseif($action -eq 7){& .\Desktop\scripts\07-intent-creation.ps1}
elseif($action -eq 8){& .\Desktop\scripts\08-0-Test-Cluster.ps1}
elseif($action -eq 9){Write-Host "9"}
elseif($action -eq 10){Write-Host "10"}
elseif($action -eq 11){Write-Host "11"}
elseif($action -eq 12){Write-Host "12"}
elseif($action -eq 13){Write-Host "13"}
elseif($action -eq 14){Write-Host "14"}
else{Write-Host "You are not selecting from options available"}








