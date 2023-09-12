powershell.exe "C:\Users\$env:username\desktop\scripts\start-sleep.ps1"
$cluster = Read-Host -Prompt "Which Cluster Are You Deploying For?"
$servers = $null
$servers =@()
do {
$input = (Read-Host "Please enter the SDN Hostname (end to Exit):")
if ($input -ne '') {$servers += $input}
}
#Loop will stop when user enter 'END' as input
until ($input -eq 'end')
Start-Sleep -Seconds 2
$servers | Format-Table
$acceptance = Read-Host -Prompt "Do you Agree to Continue (Only yes/no)" 
if($acceptance -eq 'yes')
{
    $servers | Format-Table
    $cred = Get-Credential

    $data = Invoke-Command -ComputerName ($servers) -Credential $cred  -ScriptBlock{
        ####### NUGET Install #######
        $nuget = get-packageprovider -name 'nuget' -Force
        Start-Sleep -seconds 1
        if($nuget){write-host "Nuget Already installed"} else{Install-Module -Name nuGet -Force -Confirm:$false -Force }
        Start-Sleep -Seconds 5 -Verbose

        ####### PSWindowsUpdate Install #######
        $pswindowsupdate = (Get-Module -Name PSWindowsUpdate | select name)
        Start-Sleep -Seconds 1
        if($pswindowsupdate.name -like 'PSWindowsUpdate'){Import-Module -Name PSWindowsUpdate} else{Install-Module -Name PSWindowsUpdate -Force -Confirm:$false}
        Start-Sleep -Seconds 5 -Verbose
        Invoke-WuJob -ComputerName $env:COMPUTERNAME -Script { ipmo PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -AutoReboot | Out-File "C:\Windows\PSWindowsUpdate.log"} -RunNow -Confirm:$false -Verbose -ErrorAction Ignore -Credential $cred -TaskName "update-from-jump"
    
    } ## invoke command close

echo 'Installation - Pushed, Check on each server with get-wujob command'
$data | Out-File -FilePath C:\Users\$env:username\desktop\scripts\Windowsupdate.log -Append
    
########### VALIDATION ###################
Echo "Initiating Validation Module" -Verbose
Echo "Waiting for Servers to be up"
Start-Sleep -Seconds 520 -Verbose

$finalendttime = Get-Date -Format ddMMyy-HHmmss

$Windowsupdate=Invoke-Command ($servers) -Credential $cred -ScriptBlock{Get-WindowsUpdate}

echo $Windowsupdate | select ComputerName,Title, Size | Format-Table
$name = $Windowsupdate | select computername
$name.ComputerName | Add-Content -Path "C:\Users\$env:username\desktop\scripts\windowsupdatependingservers.txt"

$countofpendingservers = Get-Content -Path "C:\Users\$env:username\desktop\scripts\windowsupdatependingservers.txt" | Measure-Object | select Count


Echo "There are $countofpendingservers "

    } #If loop for acceptance
else
{
Write-host "You Didn't Agreed"
}