import azure.functions as func

# import app into other functions files
app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

# Register blueprints from other modules
# from func_template import bp as func_template
# app.register_functions(func_template)

from functions.userinfo import bp as userinfo
app.register_functions(userinfo)

from functions.sendmessage import bp as sendmessage
app.register_functions(sendmessage)
