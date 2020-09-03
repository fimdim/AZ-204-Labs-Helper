# AZ-204 Labs Helper - Lab 03

## Architecture
![Architecture](lab03.png)

## Deployment
[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ffimdim%2FAZ-204-Labs-Helper%2Fmaster%2Flabs%2Flab03%2Ftemplate-lab03.json)

### Requirements 
In order to run the [BlobManager](BlobManager) console app, you need dotnet 3.1 .

### Steps
The easiest way to provision all the resources needed in Lab 03 is to run the [PowerShell script](deployment-script-lab03.ps1).

It has all the required steps implemented :
* Deploy Azure resources
* Upload [images](images) to the blob containers
* Update parameters in [Program.cs](BlobManager/Program.cs)
* Run the console app (optional)
