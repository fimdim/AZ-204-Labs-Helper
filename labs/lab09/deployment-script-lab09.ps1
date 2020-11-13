# Parameters
$nameSuffix=Get-Random -Maximum 100000000
$deploymentName="AZ204Lab09Deployment"
$resourceGroupName="AutomatedWorkflow"
$location="westeurope"
$tags=@{type="lab"}
$subscriptionId=(Get-AzSubscription).Id[0]

$apimName="prodapim"+$nameSuffix
$apimOrganization="Contoso"
$apimAdminEmail="admin@contoso.com"

$storageAccountName="prodstor"+$nameSuffix
$shareName = "metadata"

$apiConnectionTemplatePath=".\api-connection-template.json"

$logicAppName="prodflow"+$nameSuffix
$logicAppDefinitionFilePath=".\logic-app-template.json"
$connectionId="/subscriptions/"+$subscriptionId+"/resourceGroups/"+$resourceGroupName+"/providers/Microsoft.Web/connections/azurefile"

# Create Resource Group if it doesn't exist
Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent)
{
   New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tags -Force
}

# Create APIM
New-AzApiManagement `
   -ResourceGroupName $resourceGroupName `
   -Name $apimName `
   -Location $location `
   -Organization $apimOrganization `
   -Sku Consumption `
   -AdminEmail $apimAdminEmail

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

# Create API connection
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
   -TemplateFile $apiConnectionTemplatePath `
   -StorageAccountName $storageAccountName

# Create Logic App
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
    -TemplateFile $logicAppDefinitionFilePath `
    -Location $location `
    -LogicAppName $logicAppName