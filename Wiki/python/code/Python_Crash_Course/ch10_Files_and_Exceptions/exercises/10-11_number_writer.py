# Purpose: Use `json.dumps()` to convert data using JSON format.
# Reference: page 201 (paper) / 239 (ebook)

from pathlib import Path
import json

numbers = [2, 3, 5, 7, 11, 13]

path = Path('numbers.json')

contents = json.dumps(numbers)
#          ^--------^
# Serialize `numbers` to a JSON formatted string.

path.write_text(contents)
