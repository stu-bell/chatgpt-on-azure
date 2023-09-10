# Sample deployment commands
# You probably don't want to deploy all three options unless you're testing the templates...
# If you've updated the bicep templates, either deploy those directly or build into ARM using .\build.ps1
param(
   [Parameter(Mandatory=$true)]
   [Alias("g")]
   [string]$resourceGroup
)

Write-Host 'Deploying ARM templates...'
az deployment group create -g $resourceGroup -f .\arm\NewAzureOAI.json -p .\arm\NewAzureOAI.params.json
az deployment group create -g $resourceGroup -f .\arm\OpenAIBackend.json -p .\arm\OpenAIBackend.params.json
az deployment group create -g $resourceGroup -f .\arm\ExistingAzureOAI.json -p .\arm\ExistingAzureOAI.params.json
