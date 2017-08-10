#Login to AzureRM
Login-AzureRmAccount

#Select the subscription
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId 


#Describe Parameters
$Location = "West Europe"
$RGname = "My-ARM-VMs2"
$jsonLoc = ".\azuredeploy.json"

#ARM template variables
$VMNamePrefix = "Server-"
$vmSize = 'Standard_A2'
$SKU = '2016-Datacenter'

New-AzureRmResourceGroup -Name $rgName -Location $Location


$VMDeployment = @{
    Name = 'Workshop';
    ResourceGroupName = $RGname;
    Mode = 'Incremental';
    TemplateFile = $jsonLoc;
    TemplateParameterObject = @{
        adminUsername = '';
        adminPassword = '';
        vmNamePrefix = $VMNamePrefix;
        vnetName = $VNETName;
        vmSize = $vmSize;
        Location = $location;
        imageSKU = $SKU;
    }
}


New-AzureRmResourceGroupDeployment @VMDeployment -Verbose



