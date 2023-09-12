powershell.exe C:\Users\Administrator\Desktop\Saksham\scripts\start-sleep.ps1
$clustername = Read-Host -Prompt "What's your cluster name"
$cred = Get-Credential -UserName 'pltf\administrator' -Message "insert password"
$storagedata =  Import-Csv -Path "C:\Users\$env:USERNAME\Desktop\scripts\storage.csv"
$ipaddress = Resolve-DnsName $clustername | select ipaddress
$clusip = $ipaddress.ipaddress

$session = New-PSSession -ComputerName $clusip -Credential $cred

foreach($str in $storagedata)
{
    $data= Invoke-Command -Session $session -ScriptBlock {
    $storagepool = $using:cluster+'-s2dpool'
    $volumename= $using:clustername+$using:str.volumnename
    New-Volume -FriendlyName $volumename -FileSystem $using:str.filesystem -Size $using:str.sizeinbytes -ResiliencySettingName Mirror -ProvisioningType Thin
    }
    
    

}
Write-Host $data
