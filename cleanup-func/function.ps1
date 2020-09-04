# Input bindings are passed in via param block.
param($Timer)

# Connect Az
Connect-AzAccount -Identity

# Get and Remove resource group(s) with tag type=lab
$tags = @{type = "lab"}
Get-AzResourceGroup -Tag $tags | Remove-AzResourceGroup -Force -AsJob

#Disconnect Az
Disconnect-AzAccount
