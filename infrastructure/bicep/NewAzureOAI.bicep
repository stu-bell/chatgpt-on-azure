// Deploy a new Azure Open AI service and the frontend app

// Static Web App resource
@description('Name for Static Web App Resource')
param StaticWebAppResourceName string = 'swa-${resourceGroup().name}'

@allowed([
  'Central US'
  'East US 2'
  'East Asia'
  'West Europe'
  'West US 2'
])
@description('Region for Static Web App resource')
param StaticWebAppRegion string
@allowed([
  'Free'
  'Standard'
])
@description('Free for hobby or personal projects')
param StaticWebAppSkuName string = 'Free'

// OpenAI params
@description('Name for Azure OpenAI service resource')
param AzOpenAiResourceName string = 'oai-${resourceGroup().name}'
@description('Region name for Azure OpenAI service resource')
param AzOpenAiLocation string = resourceGroup().location
@description('Sku name for Azure OpenAI resource')
param AzOpenAiSkuName string = 'S0'
@description('The name of the model deployment')
param AzOpenAiDeploymentName string = 'azure-chat-gpt'

// OpenAI config. Only applicable if we're deploying our own Azure OpenAI service
@description('https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models')
param AzOpenAiModelName string = 'gpt-35-turbo-16k'
@description('Allowed IP addresses for Open AI. If blank, will allow any inbound request')
param AzOpenAiAllowedIpAddresses array = []

module main 'main.bicep' = {
  name: 'main-${deployment().name}'
  #disable-next-line explicit-values-for-loc-params
  params: {
    StaticWebAppResourceName: StaticWebAppResourceName
    StaticWebAppRegion: StaticWebAppRegion
    StaticWebAppSkuName: StaticWebAppSkuName

    AIProvider: 'NewAzureOAI'
    AzOpenAiResourceName: AzOpenAiResourceName
    AzOpenAiLocation: AzOpenAiLocation
    AzOpenAiSkuName: AzOpenAiSkuName
    AzOpenAiAllowedIpAddresses: AzOpenAiAllowedIpAddresses
    AzOpenAiDeploymentName: AzOpenAiDeploymentName
    AzOpenAiModelName: AzOpenAiModelName
  }
}
