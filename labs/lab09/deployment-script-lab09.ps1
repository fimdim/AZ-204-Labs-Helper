# Parameters
$deploymentName="AZ204Lab09Deployment"
$resourceGroupName="AutomatedWorkflow"
$location="West Europe"
$nameSuffix=Get-Random -Maximum 100000000
$tags=@{type="lab"}

$apimName="prodapim"+$nameSuffix
$apimOrganization="Contoso"
$apimAdminEmail="admin@contoso.com"

$storageAccountName="prodstor"+$nameSuffix
$shareName = "metadata"

$logicAppName="prodflow"+$nameSuffix
$logicAppDefinitionFilePath=".\logic-app-definition-lab09.json"

# $ParametersObj = @{
#     storageAccountName = $storageAccountName
#     tags = $tags
# }

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tags -Force

# Create APIM
New-AzApiManagement `
   -ResourceGroupName $resourceGroupName `
   -Name $apimName `
   -Location $location `
   -Organization $apimOrganization `
   -Sku Consumption `
   -AdminEmail $apimAdminEmail

New-AzLogicApp
   -ResourceGroupName $resourceGroupName
   -Name $logicAppName
   -Location $location
   -DefinitionFilePath $logicAppDefinitionFilePath

# Create Storage Account
New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName Standard_LRS `
    -Kind StorageV2 `
    -AccessTier Hot `
    -Tag $tags

New-AzRmStorageShare `
    -ResourceGroupName $resourceGroupName `
    -StorageAccountName $storageAccountName `
    -Name $shareName `
    -QuotaGiB 1

# Retrieve Storage Account key
$storageAccountKey = (Get-AzStorageAccountKey `
                        -ResourceGroupName $resourceGroupName `
                        -AccountName $storageAccountName) `
                        | Where-Object {$_.KeyName -eq "key1"}

# Get Storage Account Context
$context = New-AzStorageContext `
            -StorageAccountName $storageAccountName `
            -StorageAccountKey $storageAccountKey.value

# Upload files to fileshare
for($i = 0; $i -lt 4; $i++)
{
    $fileSource="files/item_0"+$i+".json"

    Set-AzStorageFileContent `
    -Context $context `
    -ShareName $shareName `
    -Source $fileSource
}