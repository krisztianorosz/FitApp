import sys
import requests

url = "http://localhost:7071/hello" if len(sys.argv) < 2 else sys.argv[1]
data = {"key": "value"}

resp = requests.get(url)
print(resp)
print(resp.text)

resp = requests.post(url, json=data)
print(resp)
print(resp.text)