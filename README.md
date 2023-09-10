
# Chat GPT on Azure

Front end and middleware for Azure OpenAI Service.

To deploy this you will need: 

- An Azure account
- A GitHub account
- Access to create an Azure OpenAI resource, or access to an OpenAI API

This is a personal project: it is not endorsed by Microsoft, OpenAI, my employer, or anyone else!

# Architecture
TODO: diagram + links

Frontend: Azure Static Web Apps with python middleware

Backend: Either an Azure OpenAI resource or OpenAI API

Auth: Static Web Apps user management

TODO: Azure Storage

# Deployment
To deploy this app: 

1. Run one of the Azure templates below
1. Fork the GitHub repo and deploy the app using GitHub Actions
1. Grant users access 

## Azure Templates
There are three deployment options based on the type of GPT backend you want to use:

| Backkend                    | Deploy to Azure                                                                                                                                                                                                                               | Pre-requisites                                                                                     |
| ---                         | ---                                                                                                                                                                                                                                           | ---                                                                                                |
| New Azure OAI resource      | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fstu-bell%2Fchatgpt-on-azure%2Fmain%2Finfrastructure%2Farm%2FNewAzureOAI.json)      | Ability to create an Azure OpenAI resource: https://aka.ms/oai/access                              |
| Existing Azure OAI resource | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fstu-bell%2Fchatgpt-on-azure%2Fmain%2Finfrastructure%2Farm%2FExistingAzureOAI.json) | API Endpoint and Key to an existing Azure OpenAI resource. The resource owner should provide these |
| OpenAI's API                | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fstu-bell%2Fchatgpt-on-azure%2Fmain%2Finfrastructure%2Farm%2FOpenAIBackend.json)    | An [OpenAI API key](https://platform.openai.com/account/api-keys)                                  |

At the time of writing, to deploy an Azure OpenAI resource, access must be requested at https://aka.ms/oai/access . Once Microsoft has granted access, you will be able to deploy the AzureOpenAI template. 

If you are using an existing Azure OpenAI resource, you will need the API endpoint, API key, and the name of the deployed model within the resource. The owner of the resource should provide you with these. The resource will also need to allow network access from Azure Static Web apps (see below).

TODO link how to get api key from azure or opeai. Also section below. Add budget alerts or api spending limits.

Choose one of the deployment options below, based on whether you want to create a new Azure OpenAI resource, or whether you're using an existing one.

TODO: one click deployment links

TODO template parameters for plans, ip restrictions etc

Resource group is like a folder in your azure account that will contain the app. Give it a name you'll recognise. Region specifies which data centers host your app, if you're not sure, pick the one closest to you.

## Web app deployment with GitHub Actions

Once the Azure Templates have successfully completed, you'll need to deploy the app using GitHub Actions (or Azure DevOps). 
1. In the Azure Portal(https://portal.azure.com), locate the Static Web App resource created by the templates. On the overview page, click Manage Deployment Token, and copy the token.
TODO link to deployment token
2. Fork this GitHub repository. In your forked copy of the repo, go to settings > Secrets and Variables > Actions. Create a new secret called `DEPLOY_TOKEN` and paste the token you copied from the Static Web App in the previous step. 
TODO link to forking and actions secrets
3. Run the GitHub Actions Workflow. TODO link how to do this from a fork.
4. Once the deployment has completed, in the Static Web App Azure Portal page, find the web app's URL. Open this URL in your browser and you should be presented with the webapp's login page. To add yourself as a user to the webapp, see section below on managing user access.
TODO screenshot / link
If you prefer to deploy using Azure DevOps pipelines, use the azure-pipelines.yml file and save the deployment token as a secret pipeline variable.

# Manage user access

[Manually invite users](https://learn.microsoft.com/en-us/azure/static-web-apps/authentication-custom?tabs=aad%2Cinvitations#manage-roles)
The app config assumes you'll send app user invites with a custom role called 'invited'. This will only allow users you've explicitly invited to use the app. 

If you wish to automate role assignments, rather than manually sending invites, implement an Azure Function to assign the 'invited' role to users that are allowed to use the app. [Manage Roles with an Azure Function](https://learn.microsoft.com/en-us/azure/static-web-apps/authentication-custom?tabs=aad%2Cfunction#manage-roles)

To restrict the app to members of your AAD tenant, or a specific group of users in your tenant, see the docs for configuring [Custom Authentication](https://learn.microsoft.com/en-us/azure/static-web-apps/authentication-custom?tabs=aad%2Cfunction#configure-a-custom-identity-provider)

# Add IP restrictions to your Static Web App

To restrict access to the Static Web App, (for example, to your users' VPN), modify `staticwebapp.config.json` > networking > allowedIpRanges. See the [Static Web App Networking docs](https://learn.microsoft.com/en-us/azure/static-web-apps/configuration#networking) for more info.

> Note that Static Web App network restrictions are only available on the Standard plan.
# Add IP restrictions to the Azure OpenAI service

To add network restrictions to your OpenAI resource, you'll need to know from which IP ranges your Static Web App will make requests. At the time of writing, Static Web Apps doesn't give us a way to easily find which possible IP address it might use. We can restrict access Azure IP addresses in the webapp's region. While this is still a huge range, it's better than allowing public access from the internet. If you need stronger network restrictions, checkout [this article](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/integrating-network-isolated-backends-with-azure-static-web-apps/ba-p/3721136) to integrate your Static Web App with a VNet via API Management.

Restrict OpenAI resource to the region of your Static Web App:

1. Download the list of Azure IP addresses from [this page](https://www.microsoft.com/en-us/download/details.aspx?id=56519) (updated weekly)
2. Search for the entry for `AzureCloud.`
3. Copy the array of IP address. Remove all ranges that aren't IPv4 format (eg remove all the ranges in this longer format: "2806:1010:4:802::148/125")
4. Add this list of IP addresses to the allow list of the Azure OpenAI resource. Since it's a large list, you may want to use the ARM template, with the array of IP addresses in the allowedIPAddresses parameter. 

If anyone is aware of a better way of doing this - please let me know via GitHub issues!

## Updating API keys or endpoints

In the Azure Portal, under the Keys and Endpoint menu of your Open AI resource, copy Key 1 and the Endpoint. In the Azure Open AI Studio, make a note of the model you have deployed.

In the Azure Portal, under the Configuration menu of your static web app resource, add the following application settings, replacing the values on the right hand side:

```
"AZURE_OPENAI_DEPLOYMENT_NAME": "YOUR_OAI_DEPLOYMENT_NAME",
"AZURE_OPENAI_ENDPOINT": "https://YOUR_RESOURCE_NAME.openai.azure.com/",
"AZURE_OPENAI_KEY": "YOUR_API_KEY"
```

In addition, you'll need the following settings for Python V2 model:

```
"FUNCTIONS_WORKER_RUNTIME": "python",
"AzureWebJobsFeatureFlags": "EnableWorkerIndexing",
```




# Develop and build

## Azure Static Web Apps

[Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps/overview) 

> There is an issue with the Azure Static Web Apps CLI, which causes an error when starting the dev container. 
> TODO: try installing an older version of the SWA CLI
> https://github.com/Azure/static-web-apps-cli/issues/563

## Front end

Requires [node](https://nodejs.org/)

`cd webapp`

`npm install`

Start mock static server for front end dev (run in a separate shell session to npm run start): `npm run mock` 

> Don't run the mock server at the same time as running the Azure Functions locally. Choose one or the other. Mock server is for serving static responses, while Azure Functions runs a local version of the API functions. 

Start the front end server: `npm run start`

Production build: `npm run build`

## Backend 

To run locally, requires [python](https://python.org/) and [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Cv2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-python)

> Don't run the mock server at the same time as running the Azure Functions locally. Choose one or the other. Mock server is for serving static responses, while Azure Functions runs a local version of the API functions. 

`cd webapp/api`

`pip install`

`func start`

[Python Azure Functions...](https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python?pivots=python-mode-decorators)

## API Tests

Install pytest: `pip install pytest`, or use your python test tool of choice.

From the `webapp/api` directory, run `pytest tests/unit`

To run integration tests, you'll need to configure local.settings.json and run the functions locally using Azure Function Core tools TODO link.

Run the functions locally: `func start` and then run the tests: `pytest tests/integration`. 

The default localhost port is 7071. If you need a different port, set LOCAL_FUNCTIONS_PORT=<port>.


## Deploy

TODO Deploy bicep templates

[Deploy to Azure Static Web Apps](https://learn.microsoft.com/en-gb/azure/static-web-apps/get-started-portal?tabs=vanilla-javascript&pivots=github) using GitHub Actions or Azure DevOps Pipelines


# Azure OpenAI API
https://learn.microsoft.com/en-us/azure/ai-services/openai/chatgpt-quickstart?tabs=command-line&pivots=programming-language-python
