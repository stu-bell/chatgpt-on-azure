import unittest
import json
import os

import requests

functionName = 'sendmessage'

# Default local functions port is 7071
port = os.getenv('LOCAL_FUNCTIONS_PORT', '7071')

class TestSendmessage(unittest.TestCase):
  def test_sendmessage(self):
    # Construct a mock HTTP request.
    form_data = {
        'messageHistory': json.dumps([
            {'role': 'user', 'content': 'describe a banana'},
        ])
    }

    # invoke
    resp = requests.post(f"http://localhost:{port}/api/{functionName}?", data=form_data)

    print(resp.status_code)
    print(resp.text)

    # Check the output.
    self.assertEqual(
        resp.status_code,
        200
    )