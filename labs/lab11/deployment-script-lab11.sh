#/bin/bash

echo Parameters
resourceGroupName="AsyncProcessor"
location="westeurope"
suffix=$RANDOM
storageAccountName="asyncstor"$suffix

echo Create Resource Group
az group create -l $location -n $resourceGroupName --tags type=lab

echo Create Storage Account
az storage account create -l $location -n $storageAccountName -g $resourceGroupName --access-tier hot --kind StorageV2 --sku Standard_LRS

echo Get Storage Account connection string
connectionString=$(az storage account show-connection-string -n asyncstorfiras -g AsyncProcessor --query connectionString -o tsv)

echo Update storage-connection-string in MessageProcessor program
search="<storage-connection-string>"
replace=$(echo $connectionString | sed 's/\//\\\//g')
sed -i "s/${search}/${replace}/g" MessageProcessor/Program.cs

# echo If dotnet 3.1 is installed
#cd EventPublisher
#dotnet run
