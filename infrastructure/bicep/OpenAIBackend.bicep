// Deploy webapp and configure with OpenAI's API: https://platform.openai.com/

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

// static web app config
@description('Static Web App Config will be overwritten with default values, unless this is set to false')
param StaticWebAppOverwriteConfig bool = true
@description('API access key for Open AI service')
@secure()
param OpenAiEndpointKey string
@description('The name of the model to use https://platform.openai.com/docs/models')
param OpenAiModelName string = 'gpt-3.5-turbo'

module main 'main.bicep' = {
  name: 'main-${deployment().name}'
  #disable-next-line explicit-values-for-loc-params
  params: {
    StaticWebAppResourceName: StaticWebAppResourceName
    StaticWebAppRegion: StaticWebAppRegion
    StaticWebAppSkuName: StaticWebAppSkuName
    StaticWebAppOverwriteConfig: StaticWebAppOverwriteConfig

    AIProvider: 'OpenAI'
    OpenAiEndpointKey: OpenAiEndpointKey
    OpenAiModelName: OpenAiModelName
  }
}
