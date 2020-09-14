#/bin/bash

echo Parameters
resourceGroupName="PubSubEvents"
location="westeurope"
suffix=$RANDOM
eventGridTopicName="hrtopic"$suffix
appServicePlanName="EventPlan"
webAppNameName="eventviewer"$suffix
subscriptionName="basicsub"
subscriptionEndpoint="https://$webAppNameName.azurewebsites.net/api/updates"

echo Get Subscription ID
subscriptionId=$(az account show --query id -o tsv)
eventGridResourceId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.EventGrid/topics/$eventGridTopicName"

echo Register Microsoft.EventGrid Provider
az provider register --namespace Microsoft.EventGrid

echo Create Resource Group
az group create -l $location -n $resourceGroupName --tags type=lab

echo Create EventGridTopic
az eventgrid topic create -l $location -n $eventGridTopicName -g $resourceGroupName

echo Create AppServicePlan
az appservice plan create -n $appServicePlanName -g $resourceGroupName -l $location --sku P1V2 --is-linux

echo Create WebApp
az webapp create -n $location -g $resourceGroupName -p $appServicePlanName -n $webAppNameName -i "microsoftlearning/azure-event-grid-viewer:latest"

echo Create EventGrid subscription
az eventgrid event-subscription create -n $subscriptionName --source-resource-id $eventGridResourceId --endpoint $subscriptionEndpoint --endpoint-type webhook

echo Get Topic key
endpoint=$(az eventgrid topic show -n $eventGridTopicName -g $resourceGroupName --query endpoint -o tsv)
key=$(az eventgrid topic key list -n $eventGridTopicName -g $resourceGroupName --query key1 -o tsv)

echo Update Topic-Endpoint in EventPublisher program
search="private const string topicEndpoint"
replace=$(echo "private const string topicEndpoint = \""$endpoint"\";" | sed 's/\//\\\//g')
sed -i "/${search}/c${replace}" EventPublisher/Program.cs

echo Update Topic-Key in EventPublisher program
search="private const string topicKey"
replace=$(echo "private const string topicKey = \""$key"\";" | sed 's/\//\\\//g')
sed -i "/${search}/c${replace}" EventPublisher/Program.cs

# echo If dotnet 3.1 is installed
# cd EventPublisher
# dotnet run