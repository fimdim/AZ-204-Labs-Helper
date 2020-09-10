#/bin/bash
# Parameters
resourceGroupName="PubSubEvents"
location="westeurope"
suffix=$RANDOM
eventGridTopicName="hrtopic"$suffix
appServicePlanName="EventPlan"
webAppNameName="eventviewer"$suffix
subscriptionName="basicsub"
subscriptionEndpoint="https://$webAppNameName.azurewebsites.net/api/updates"
# Get Subscription ID
subscriptionId=$(az account show --query id -o tsv)
eventGridResourceId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.EventGrid/topics/$eventGridTopicName"
# Register Microsoft.EventGrid Provider
az provider register --namespace Microsoft.EventGrid
# Create Resource Group
az group create -l $location -n $resourceGroupName --tags type=lab
# Create EventGridTopic
az eventgrid topic create -l $location -n $eventGridTopicName -g $resourceGroupName
# Create AppServicePlan
az appservice plan create -n $appServicePlanName -g $resourceGroupName -l $location --sku P1V2 --is-linux
# Create WebApp
az webapp create -n $location -g $resourceGroupName -p $appServicePlanName -n $webAppNameName -i "microsoftlearning/azure-event-grid-viewer:latest"
# Create EventGrid subscription
az eventgrid event-subscription create -n $subscriptionName --source-resource-id $eventGridResourceId --endpoint $subscriptionEndpoint --endpoint-type webhook
# Get Topic key
endpoint=$(az eventgrid topic show -n $eventGridTopicName -g $resourceGroupName --query endpoint -o tsv)
key=$(az eventgrid topic key list -n $eventGridTopicName -g $resourceGroupName --query key1 -o tsv)
# Update Topic-Endpoint in EventPublisher program
search="<Topic-Endpoint>"
replace=$endpoint
sed -i "s/${search}/${replace}/g" EventPublisher/Program.cs
# Update Topic-Key in EventPublisher program
search="<Topic-Key>"
replace=$key
sed -i "s/${search}/${replace}/g" EventPublisher/Program.cs
# If dotnet 3.1 is installed
#cd EventPublisher
#dotnet run