# Parameters
$deploymentName="AZ204CleanupFunctionDeployment"
$resourceGroupName="rg-cleanup"
$location="West Europe"

$suffix=Get-Random -Maximum 100000

$functionAppName="func-cleanup"+$suffix
$hostingPlanName="plan-cleanup"+$suffix
$applicationInsightsName="appi-cleanup"+$suffix
$storageAccountName="stcleanup"+$suffix

$ParametersObj = @{
    functionAppName=$functionAppName
    hostingPlanName=$hostingPlanName
    applicationInsightsName=$applicationInsightsName
    storageAccountName=$storageAccountName
}

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Resource Group Deployment
New-AzResourceGroupDeployment -Name $deploymentName -Mode Complete -ResourceGroupName $resourceGroupName -TemplateFile 'template-cleanup-func.json' -TemplateParameterObject $ParametersObj -Force

# Create a new role assignment for the Function App (Contributor at the current subscription level)
$subscriptionId=(Get-AzSubscription).Id
$objectId = (Get-AzADServicePrincipal -DisplayName $functionAppName).id
New-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName Contributor -Scope /subscriptions/$subscriptionId
