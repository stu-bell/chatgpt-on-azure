import logging
import azure.functions as func
import os
import requests
import json
import openai
from shared_code.user_auth import is_user_authorized
from shared_code.user_auth import get_user_info

# Register blueprint in function_app.py
bp = func.Blueprint()


# suggest file name the same as function name
# function name must be unique in the app. Route defaults to function name?
@bp.route()
def sendmessage(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("SendMessage triggered")
    try:
        if not is_user_authorized(get_user_info(req)):
            return func.HttpResponse("UNAUTHORIZED", status_code=401)

        # Which service is providing AI? Options: 'azure' or 'openai'
        ai_provider = os.getenv("AI_PROVIDER", "openai")

        if ai_provider == "azure":
            openai.api_key = os.getenv("AZURE_OPENAI_KEY")
            # api_base: endpoint should look like: https://YOURENDPOINT.openai.azure.com/
            openai.api_base = os.getenv("AZURE_OPENAI_ENDPOINT")
            # deployment_name: The custom name you chose for your deployment when you deployed a model
            deployment_name = os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME")
            openai.api_type = "azure"
            openai.api_version = "2023-05-15" # may change in future
            model_name = None
        elif ai_provider == "openai":
            deployment_name = None
            model_name = os.getenv("OPENAI_MODEL_NAME", "gpt-3.5-turbo")
            openai.api_key = os.getenv("OPENAI_API_KEY")

        messageHistory = json.loads(req.form.get("messageHistory"))
        systemMessage = {
            "role": "system",
            "content": "You are a helpful assistant. If asked who or what or where you are, respond with: I am a GPT language model, developed by OpenAI but hosted within your organization's Microsoft Azure environment.",
        }
        response = openai.ChatCompletion.create(
            model=model_name,  # For OpenAI backend
            engine=deployment_name,  # For Azure backend
            messages=[systemMessage] + messageHistory,
        )
        # logging.info(response)
        return func.HttpResponse(
            response["choices"][0]["message"]["content"], status_code=200
        )

    except Exception as e:
        # If there's an error in the try block, return the error message
        return func.HttpResponse(f"Error: {str(e)}", status_code=500)


# name = req.params.get('name')
# if not name:
#     try:
#         req_body = req.get_json()
#     except ValueError:
#         pass
#     else:
#         name = req_body.get('name')
