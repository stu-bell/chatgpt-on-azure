# build bicep files into arm templates for one-click deployments
Write-Host 'Building ARM templates...'
az bicep build --outdir arm -f bicep\NewAzureOAI.bicep
az bicep build --outdir arm -f bicep\ExistingAzureOAI.bicep
az bicep build --outdir arm -f bicep\OpenAIBackend.bicep
