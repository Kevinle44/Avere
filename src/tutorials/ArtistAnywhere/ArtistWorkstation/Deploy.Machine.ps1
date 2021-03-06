param (
    # Set a name prefix for the Azure resource groups that are created by this resource deployment script
    [string] $resourceGroupNamePrefix = "Azure.Artist.Anywhere",

    # Set the Azure region name for compute resources (e.g., Image Gallery, Virtual Machine Scale Set, HPC Cache, etc.)
    [string] $computeRegionName = "WestUS2",

    # Set the Azure region name for storage resources (e.g., Storage Network, Storage Account, File Share/Container, etc.)
    [string] $storageRegionName = "EastUS2",

    # Set to true to deploy Azure VPN Gateway (https://docs.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpngateways)
    [boolean] $networkGatewayDeploy = $false,

    # Set to true to deploy Azure NetApp Files (https://docs.microsoft.com/azure/azure-netapp-files/azure-netapp-files-introduction)
    [boolean] $storageNetAppDeploy = $false,

    # Set to true to deploy Azure HPC Cache (https://docs.microsoft.com/azure/hpc-cache/hpc-cache-overview) in the compute region
    [boolean] $storageCacheDeploy = $false,

    # Set the operating system types for the Azure artist workstation image builds and virtual machines
    [string[]] $artistWorkstationTypes = @("Linux", "Windows"),

    # The base Azure services framework (e.g., Virtual Network, Managed Identity, Key Vault, etc.)
    [object] $baseFramework,

    # The Azure storage and cache service resources (e.g., storage account, cache mount, etc.)
    [object] $storageCache,

    # The Azure render manager
    [object] $renderManager
)

$rootDirectory = !$PSScriptRoot ? $using:rootDirectory : (Get-Item -Path $PSScriptRoot).Parent.FullName
$moduleDirectory = "ArtistWorkstation"

Import-Module "$rootDirectory/Deploy.psm1"
Import-Module "$rootDirectory/BaseFramework/Deploy.psm1"
# Import-Module "$rootDirectory/StorageCache/Deploy.psm1"

# Base Framework
if (!$baseFramework) {
    $baseFramework = Get-BaseFramework $rootDirectory $resourceGroupNamePrefix $computeRegionName $storageRegionName $networkGatewayDeploy
}
$computeNetwork = $baseFramework.computeNetwork
$managedIdentity = $baseFramework.managedIdentity
$imageGallery = $baseFramework.imageGallery

# Storage Cache
# if (!$storageCache) {
#     $storageCache = Get-StorageCache $rootDirectory $baseFramework $resourceGroupNamePrefix $computeRegionName $storageRegionName $storageNetAppDeploy $storageCacheDeploy
# }

# (21) Artist Workstation Machine
$moduleName = "(21) Artist Workstation Machine [" + ($artistWorkstationTypes -join ",") + "]"
New-TraceMessage $moduleName $false
$resourceGroupNameSuffix = "-Workstation"
$resourceGroupName = Set-ResourceGroup $resourceGroupNamePrefix $resourceGroupNameSuffix $computeRegionName

$templateFile = "$rootDirectory/$moduleDirectory/21-Machine.json"
$templateParameters = "$rootDirectory/$moduleDirectory/21-Machine.Parameters.json"

$templateConfig = Get-Content -Path $templateParameters -Raw | ConvertFrom-Json
$templateConfig.parameters.managedIdentity.value.name = $managedIdentity.name
$templateConfig.parameters.managedIdentity.value.resourceGroupName = $managedIdentity.resourceGroupName
$templateConfig.parameters.imageGallery.value.name = $imageGallery.name
$templateConfig.parameters.imageGallery.value.resourceGroupName = $imageGallery.resourceGroupName

$scriptParameters = $templateConfig.parameters.scriptExtension.value.scriptParameters
$scriptParameters.RENDER_MANAGER_HOST = $renderManager.host ?? ""
$fileParameters = Get-ObjectProperties $scriptParameters $false
$templateConfig.parameters.scriptExtension.value.fileParameters = $fileParameters

$templateConfig.parameters.virtualNetwork.value.name = $computeNetwork.name
$templateConfig.parameters.virtualNetwork.value.resourceGroupName = $computeNetwork.resourceGroupName
$templateConfig | ConvertTo-Json -Depth 10 | Out-File $templateParameters

$groupDeployment = (az deployment group create --resource-group $resourceGroupName --template-file $templateFile --parameters $templateParameters) | ConvertFrom-Json
$artistWorkstations = $groupDeployment.properties.outputs.artistWorkstations.value
New-TraceMessage $moduleName $true
