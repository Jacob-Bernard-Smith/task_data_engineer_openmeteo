## Used to test an API connection from UNIX environment.

import requests
response = requests.get("https://randomfox.ca/floof")
"""print(response.status_code)
print(response.text)
print(response.json())"""
fox = response.json()
print(fox['image'])