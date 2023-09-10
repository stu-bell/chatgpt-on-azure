# For programatic user management
# Complete shared_code.user_auth.is_user_authorized to determine if a user should have access or not
# https://learn.microsoft.com/en-gb/azure/static-web-apps/authentication-custom?tabs=aad%2Cfunction#manage-roles
import logging
import azure.functions as func
import json
from shared_code.user_auth import is_user_authorized

# Register blueprint in function_app.py
bp = func.Blueprint() 
# suggest file name the same as function name
# function name must be unique in the app. Route defaults to function name
@bp.route()
def getroles(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('GetRoles triggered')

    # TODO confirm what form the request comes through
    # TODO configure rolesSource in staticwebapp.config.json https://learn.microsoft.com/en-gb/azure/static-web-apps/authentication-custom?tabs=aad%2Cfunction#configure-a-function-for-assigning-roles
    clientPrincipal = req.get_json()

    try: 
        if is_user_authorized(clientPrincipal):
            roles = {
                roles: ["invited"]
            }
        else:
            roles = {
                roles: []
            }
        return func.HttpResponse(json.dumps(roles), status_code=200)

    except:
        return "an error occured in user_auth"
        # return func.HttpResponse( "msg", status_code=200)
