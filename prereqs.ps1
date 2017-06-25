# Install and configure Azure PowerShell
# Step 1: Install PowerShellGet
Get-Module PowerShellGet -list | Select-Object Name,Version,Path
# PowerShellGet 1.0.0.1 C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\1.0.0.1\PowerShellGet.psd1



# Step 2: Install Azure PowerShell
# Install the Azure Resource Manager modules from the PowerShell Gallery
Install-Module AzureRM

# Step 3: Load the AzureRM module
Import-Module AzureRM




# Checking the version of Azure PowerShell
Get-Module AzureRM -list | Select-Object Name,Version,Path

# Install the Azure Resource Manager modules from the PowerShell Gallery
Install-Module AzureRM -AllowClobber