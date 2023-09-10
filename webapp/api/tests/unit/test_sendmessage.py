import urllib.parse
import unittest
import azure.functions as func

from functions.sendmessage import sendmessage as function_under_test

class TestSendmessage(unittest.TestCase):
  def test_sendmessage(self):
    # Construct a mock HTTP request.
    form_data = {
        'messageHistory': [
            {'role': 'user', 'content': 'some_content'},
        ]
    }
    req = func.HttpRequest(method='POST',
                           body=urllib.parse.urlencode(form_data).encode(),
                           url='/api/sendmessage',
                           headers={
                              'content-type': 'application/x-www-form-urlencoded'
                           })


    # Call the function.
    # TODO mocks
    resp = function_under_test(req)
    print(resp)

    # Check the output.
    self.assertEqual(
        resp.get_body(),
        # TODO: expected response
        b'21 * 2 = 42',
    )