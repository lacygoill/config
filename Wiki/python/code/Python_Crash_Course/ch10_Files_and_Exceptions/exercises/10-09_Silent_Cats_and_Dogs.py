# Purpose: Modify your except block in  Exercise 10-8 to fail silently if either
# file is missing.
#
# Reference: page 200 (paper) / 238 (ebook)

from pathlib import Path

try:
    path = Path('cats.txt')
    contents = path.read_text(encoding='utf-8')
    print(contents, end='')

    path = Path('dogs.txt')
    contents = path.read_text(encoding='utf-8')
    print(contents, end='')
except FileNotFoundError:
    pass
