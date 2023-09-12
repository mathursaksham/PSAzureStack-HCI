
#Arc Register
$a = Get-Module -ListAvailable -name az.stackhci | select Version
$b = $a.Version
if ($b -gt '2.0.0') {Write-Host "Version $b available"} else {Install-Module -Name Az.StackHCI -MinimumVersion 2.0.0}

Start-Sleep -Seconds 10

$clustername =  Read-Host "Please Input Clustername"
$SubscriptionId = Read-Host "Please Input Subscription ID"


$azureAppCred = (New-Object System.Management.Automation.PSCredential "eb0dc05a-77ef-429a-a3aa-eb51d04b43ed", (ConvertTo-SecureString -String "-GK8Q~rL55JjO2WspJbFrgefK4hHQFvvDvXRfb6y" -AsPlainText -Force))

Start-Sleep -Seconds 2 

Connect-AzAccount -ServicePrincipal -Subscription $SubscriptionId -Tenant "efa9e506-9dbf-419b-9fab-bd7e19969329" -Credential $azureAppCred

#Register the Cluster

$armtoken =Get-AzAccessToken
$azureLocation ='centralindia'
$ArcServerResourceGroupName ='rg-meg2-platform-arc-enabled-nodes'
$ResourceGroupName ='rg-meg2-platform-cluster'
$AccountId = 'eb0dc05a-77ef-429a-a3aa-eb51d04b43ed'
$tags = @{"Platform"="True"; "PlatformRole"="Cluster";"Role"="AzureStackHCICluster"}

Start-Sleep -Seconds 5

Write-Host "Registration Starts Now"
 
Register-AzStackHCI -SubscriptionId $SubscriptionId -AccountId $armtoken.UserId -ArmAccessToken $armtoken.Token -ArcServerResourceGroupName $ArcServerResourceGroupName -Credential (Get-Credential) -Region $azureLocation -ResourceName $clustername -ResourceGroupName $ResourceGroupName -Tag $tags
