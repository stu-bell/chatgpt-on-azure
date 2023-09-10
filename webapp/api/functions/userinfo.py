import logging
import azure.functions as func
from shared_code.user_auth import is_user_authorized
from shared_code.user_auth import get_user_info

# Register blueprint in function_app.py
bp = func.Blueprint() 
# suggest file name the same as function name
# function name must be unique in the app. Route defaults to function name?
@bp.route()
def userinfo(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('userinfo triggered')
    try:
        user_info = get_user_info(req)

        if not is_user_authorized(user_info):
            return func.HttpResponse("UNAUTHORIZED", status_code=401)

        userName = user_info.get('userDetails')
        return func.HttpResponse(userName)

    except Exception as e:
        return func.HttpResponse(f"Error: {str(e)}", status_code=500)
