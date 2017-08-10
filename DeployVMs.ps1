#Login to AzureRM
Login-AzureRmAccount

#Select the subscription
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId 


#variable values
$Location = "West Europe"
$RGname = "MyTestLab"
$VNETname = "MyVNET"

#Create Resource Group
New-AzureRmResourceGroup -Name $RGname -Location $Location

#region Create VNET and Subnet
#Create Virtual Network
Register-AzureRmResourceProvider -ProviderNamespace microsoft.network
$newVNET = New-AzureRmVirtualNetwork -Name $VNETname -ResourceGroupName $RGname -Location $Location -AddressPrefix "168.10.0.0/16" 


#Create frontend and backend Subnets.
#It is used to add a subnet to the in-memory representation of the VNET
Add-AzureRmVirtualNetworkSubnetConfig -Name "FrontEndSubnet" -VirtualNetwork $newVNET -AddressPrefix "168.10.1.0/24" 
Add-AzureRmVirtualNetworkSubnetConfig -Name "BackEndSubnet" -VirtualNetwork $newVNET -AddressPrefix "168.10.2.0/24" 

help Add-AzureRmVirtualNetworkSubnetConfig -ShowWindow

Set-AzureRmVirtualNetwork -VirtualNetwork $newVNET
#endregion

#region

#Create Network Card Interface
$getmyVNET = Get-AzureRmVirtualNetwork -ResourceGroupName $RGname -Name $VNETname

$nic = New-AzureRmNetworkInterface -ResourceGroupName $RGname -Location $Location -Name justNic -SubnetId $getmyVNET.Subnets[0].Id
 -PublicIpAddressId $publicIP.Id 
#$nic = Get-AzureRmNetworkInterface -ResourceGroupName $RGname -Name justNic

#NSG Create Rules
$nsgRDP = New-AzureRmNetworkSecurityRuleConfig -Name AllowRDP -Protocol Tcp -Direction Inbound -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389 `
  -Access Allow

$nsgBlock = New-AzureRmNetworkSecurityRuleConfig -Name BlockAll -Protocol * -Direction Inbound -Priority 4000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange * `
  -Access Deny

#Create Network Security Group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $RGname -Location $Location -Name "NSGFrontEnd" -SecurityRules $nsgRDP, $nsgBlock

#Assign NSG to the Subnet
Set-AzureRmVirtualNetworkSubnetConfig -Name "FrontEndSubnet" -VirtualNetwork $newVNET -NetworkSecurityGroup $nsg -AddressPrefix 168.10.1.0/24
Set-AzureRmVirtualNetwork -VirtualNetwork $newVNET

#endregion


#region Create VM
#Login details for the VM
$VMcred = Get-Credential

#region Get SKUs, sizes
#Get available VM sizes in location
Get-AzureRmVMSize -Location $Location

#Get Image publisher
Get-AzureRmVMImagePublisher -Location $Location 

#Get available Images
Get-AzureRmVMImageOffer -Location $Location -PublisherName "MicrosoftWindowsServer" 

#Get SKUs
Get-AzureRmVMImageSku -Location $Location -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer"
#endregion

#Create VM configuration
$vmConfig = New-AzureRmVMConfig -VMName "Server-X" -VMSize Standard_A2 |
  Set-AzureRmVMOperatingSystem -Windows -ComputerName "Server-X" -Credential $VMcred |
  Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest |
  Add-AzureRmVMNetworkInterface -Id $nic.Id

New-AzureRmVM -ResourceGroupName $RGname -Location $Location -VM $vmConfig
#endregion



$nic = Get-AzureRmNetworkInterface -Name justnic -ResourceGroupName $RGname


#region Create Load Balancer
$publicIP = New-AzureRmPublicIpAddress -Name LB2pip -ResourceGroupName $RGname -Location $Location -AllocationMethod Static
$frontendIP = New-AzureRmLoadBalancerFrontendIpConfig -Name LoadBalancer-FE -PublicIpAddress $publicIP
#######################
$beaddresspool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name LoadBalancer-BE

#OK
$inboundNATRule = New-AzureRmLoadBalancerInboundNatRuleConfig -Name allowRDP -FrontendIpConfiguration $frontendIP -Protocol TCP -FrontendPort 33445 -BackendPort 3389
$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name HealthProbe -Protocol Tcp -Port 80 -IntervalInSeconds 15 -ProbeCount 2
#Creating a load balancer
$LB = New-AzureRmLoadBalancer -ResourceGroupName $RGname -Name LoadBalancer -Location $Location -FrontendIpConfiguration $frontendIP -InboundNatRule $inboundNATRule -BackendAddressPool $beAddressPool -Probe $healthProbe


#############################################################################################################################################
$nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $beaddresspool
$nic.IpConfigurations[0].LoadBalancerInboundNatRules.Add($lb.InboundNatRules[0])
Set-AzureRmNetworkInterface -NetworkInterface $nic
#OK



#$ip = (Get-AzureRmPublicIpAddress -ResourceGroupName $RGname).IpAddress[0]
$ip = (Get-AzureRmPublicIpAddress -ResourceGroupName $RGname).IpAddress
mstsc /v:$ip':33445'
