// To deploy a new Azure OpenAI service, you will need to request access: https://aka.ms/oai/access
@allowed([
  'NewAzureOAI'
  'ExistingAzureOAI'
  'OpenAI'
])
@description('Are you connecting to an existing OpenAI backend service or deploying a new Azure OpenAI backend service?')
param AIProvider string = 'NewAzureOAI'

// OpenAI params
@description('Name for Azure OpenAI service resource. Ignore if using existing OpenAI service')
param AzOpenAiResourceName string = 'oai-${resourceGroup().name}'
@description('Region name for Azure OpenAI service resource. Ignore if using existing OpenAI service')
param AzOpenAiLocation string = resourceGroup().location
@description('Sku name for Azure OpenAI resource. Ignore if using existing OpenAI service')
param AzOpenAiSkuName string = 'S0'

// OpenAI config. Only applicable if we're deploying our own Azure OpenAI service
@description('https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models Ignore if using existing OpenAI service')
param AzOpenAiModelName string = 'gpt-35-turbo-16k'
@description('Allowed IP addresses for Open AI. If blank, will allow any inbound request. Ignore if using an existing Open AI service')
param AzOpenAiAllowedIpAddresses array = []

// Static Web App resource
@description('Name for Static Web App Resource')
param StaticWebAppResourceName string = 'swa-${resourceGroup().name}'

// Static Web Apps are currently only available in these regions: 
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

@description('API endpoint for Open AI service. Ignore if deploying a new OpenAI backend service')
param AzOpenAiEndpoint string = 'https://YOUR_OPENAI_ENDPOINT.openai.azure.com/'
@description('API access key for Open AI service. Ignore if deploying a new OpenAI backend service')
@secure()
#disable-next-line secure-parameter-default
param OpenAiEndpointKey string = ''
@description('The name of the model deployment from the Azure Open AI studio')
param AzOpenAiDeploymentName string = (AIProvider == 'NewAzureOAI') ? 'azure-chat-gpt' : '-'
@description('Model name: https://platform.openai.com/docs/models Ignore if using Azure OpenAI backend')
param OpenAiModelName string = (AIProvider == 'OpenAI') ? 'gpt-3.5-turbo' : ''

// deploy a new openai resource?
var NewAzureOAI = (AIProvider == 'NewAzureOAI')
var ExistingAzureOAI = (AIProvider == 'ExistingAzureOAI')
metadata author = 'Stuart Bell'
metadata licence = 'MIT'
metadata repo = 'https://github.com/stu-bell/'

// select the location code from the option chosen in staticWebAppRegion
@description('Set by parameter Static Web App Region')
param StaticWebAppLocation string = {
  'Central US': 'centralus'
  'East US 2': 'eastus2'
  'East Asia': 'eastasia'
  'West Europe': 'westeurope'
  'West US 2': 'westus2'
}[StaticWebAppRegion]

// OpenAI service
resource oai 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (NewAzureOAI) {
  name: AzOpenAiResourceName
  location: AzOpenAiLocation
  sku: {
    name: AzOpenAiSkuName
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: guid(resourceGroup().name, AzOpenAiResourceName)
    networkAcls: {
      defaultAction: ((length(AzOpenAiAllowedIpAddresses) == 0) ? 'Allow' : 'Deny')
      virtualNetworkRules: []
      ipRules: [for item in AzOpenAiAllowedIpAddresses: {
        value: replace(item, '/32', '')
      }]
    }
    publicNetworkAccess: 'Enabled'
  }

  // deploy a model inside the OpenAI service
  resource oaiDeployment 'deployments@2023-05-01' = {
    name: AzOpenAiDeploymentName
    sku: {
      name: 'Standard'
      capacity: 30
    }
    properties: {
      model: {
        format: 'OpenAI'
        name: AzOpenAiModelName
        version: '0613'
      }
      versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
      raiPolicyName: 'SafeOnly'
    }
  }
}

// SWA settings if using OpenAI backend
var openAiSettings = {
  OPENAI_MODEL_NAME: OpenAiModelName
  OPENAI_API_KEY: OpenAiEndpointKey
}

// SWA settings if using Azure OpenAI backend
var AzureOAISettings = {
  AI_PROVIDER: 'azure'
  AZURE_OPENAI_DEPLOYMENT_NAME: AzOpenAiDeploymentName
  AZURE_OPENAI_ENDPOINT: NewAzureOAI ? oai.properties.endpoint : AzOpenAiEndpoint
  #disable-next-line use-resource-symbol-reference
  AZURE_OPENAI_KEY: NewAzureOAI ? listKeys(oai.id, '2023-05-01').key1 : OpenAiEndpointKey
}

// Static Web App
resource staticWebAppResource 'Microsoft.Web/staticSites@2022-09-01' = {
  name: StaticWebAppResourceName
  location: StaticWebAppLocation
  sku: {
    name: StaticWebAppSkuName
  }
  properties: {
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Disabled'
  }

  resource appsettings 'config@2022-09-01' = if (StaticWebAppOverwriteConfig) {
    name: 'appsettings'
    properties: (NewAzureOAI || ExistingAzureOAI) ? AzureOAISettings : openAiSettings
  }
}

output staticWebAppResourceId string = staticWebAppResource.id
output staticWebAppDefaultHostname string = staticWebAppResource.properties.defaultHostname
