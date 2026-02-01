# Purpose: Writing a single line into a file.
# Reference: page 190 (paper) / 228 (ebook)

from pathlib import Path

contents = 'I love programming.\n'
contents += 'I love creating new games.\n'
contents += 'I also love working with data.\n'

path = Path('programming.txt')
path.write_text(contents)
