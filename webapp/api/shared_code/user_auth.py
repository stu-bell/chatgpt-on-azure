import base64
import json
import azure.functions as func
import os

# don't require auth if running locally for dev
# don't set this setting in a production app as anyone will be able to access the app
skipMsg = 'LOCAL_DEV_SKIP_AUTH = true: skipping authentication!!!'
local_dev_skip_auth = os.getenv('LOCAL_DEV_SKIP_AUTH') 

# If using programatic role management, complete the condition below to allow/deny users
# Ignore this if you're using the Azure Static WebApp manual invitations system
# https://learn.microsoft.com/en-gb/azure/static-web-apps/authentication-custom?tabs=aad%2Cinvitations#manage-roles
def is_user_authorized(clientPrincipal):
    if local_dev_skip_auth:
        print(skipMsg)
        return True
    else:
        # ClientPrincipal looks like
        # {"identityProvider":"aad","userId":"INTERNAL_ID","userDetails":"EMAIL","userRoles":["invited","anonymous","authenticated"]}
        # {"identityProvider":"aad","userId":"INTERNAL_ID","userDetails":"EMAIL","claims":[{"typ":"...", "val":""}]}
    
        # Complete this condition:
        # true => authorized
        # false => unauthorized
        user_is_authorized = (
            ########### WARNING ###########
            # If removing this condition:
            # ensure staticwebapp.config.json is protecting "/api/*" and "/" with 'invited' role
            # Otherwise, anyone will be able to register and use the app without authorization
            ###############################
            True
        )
        return user_is_authorized


# get_user_info returns clientPrincipal object from function request
# Only applicable to Azure Static Web Apps: https://learn.microsoft.com/en-gb/azure/static-web-apps/user-information?tabs=javascript#api-functions
# returns an object like: {"identityProvider":"aad","userId":"INTERNAL_ID","userDetails":"EMAIL","userRoles":["CUSTOM_ROLES","anonymous","authenticated"]}
def get_user_info(req: func.HttpRequest):
    if local_dev_skip_auth:
        print(skipMsg)
        return {}
    else:
        header = req.headers['x-ms-client-principal']
        clientPrincipal = base64.b64decode(header).decode('ascii')
        return json.loads(clientPrincipal)
