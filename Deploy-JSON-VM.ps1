#Login to AzureRM
Login-AzureRmAccount

#Select the subscription
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId 


#Describe Parameters
$Location = "West Europe"
$RGname = "Marty-ARM-DeployVMs"
$jsonLoc = "D:\OneDrive\Cloud\VStudioProjects\LB-VM\LB-VM\azuredeploy.json"

#ARM template variables
$vmUsername = 'marvlk'
$VMPassword = 'AnotherPass789'
$VMNamePrefix = "Server-"
$vmSize = 'Standard_A2'
$SKU = '2016-Datacenter'

New-AzureRmResourceGroup -Name $rgName -Location $Location


$VMDeployment = @{
    Name = 'JuneWorkshop';
    ResourceGroupName = $RGname;
    Mode = 'Incremental';
    TemplateFile = $jsonLoc;
    TemplateParameterObject = @{
        adminUsername = $vmUsername;
        adminPassword = $VMPassword;
        vmNamePrefix = $VMNamePrefix;
        vnetName = $VNETName;
        vmSize = $vmSize;
        Location = $location;
        imageSKU = $SKU;
    }
}


New-AzureRmResourceGroupDeployment @VMDeployment -Verbose



