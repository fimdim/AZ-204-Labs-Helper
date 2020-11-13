# AZ-204 Labs Helper - Lab 09

## Architecture
TBD

### Steps
The easiest way to provision all the resources needed in Lab 09 is to run the [PowerShell script](deployment-script-lab09.ps1).

It has all the required steps implemented :
* Deploy Azure resources:
** Storage account
** Logic app
** API Management
* Implement a workflow using Logic Apps
* Use Azure API Management as a proxy for Logic Apps

One single manual step is required in the Azure portal - after the script finishes - in the API management created by the script, add a Logic App API pointing at the Logic App instance created by the script.

### Lab Excercises

![Exercises](files/az204-lab09.jpeg)
