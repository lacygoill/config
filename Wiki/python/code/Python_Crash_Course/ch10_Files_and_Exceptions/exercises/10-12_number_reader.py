# Purpose: Use `json.loads()` to read data using JSON format.
# Reference: page 202 (paper) / 240 (ebook)

from pathlib import Path
import json

path = Path('numbers.json')
contents = path.read_text()

numbers = json.loads(contents)
#         ^--------^
# Deserialize `contents`, containing a JSON document, to a Python object.

print(numbers)
#     [2, 3, 5, 7, 11, 13]
