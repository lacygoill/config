# Purpose: Working with Multiple Files
# Reference: page 197 (paper) / 235 (ebook)

from pathlib import Path

def count_words(path):
    """Count the approximate number of words in a file."""
    try:
        contents = path.read_text(encoding='utf-8')
    except FileNotFoundError:
        print(f'Sorry, the file {path} does not exist.')
    else:
        # Count the approximate number of words in the file:
        words = contents.split()
        num_words = len(words)
        print(f'The file {path} has about {num_words} words.')

# NOTE: The files can be downloaded from: https://gutenberg.org/
# Here, we downloaded all files, except `siddhartha.txt`.
filenames = ['alice.txt', 'siddhartha.txt', 'moby_dick.txt', 'little_women.txt']
for filename in filenames:
    path = Path(filename)
    count_words(path)
#     The file alice.txt has about 30389 words.
#     Sorry, the file siddhartha.txt does not exist.
#     The file moby_dick.txt has about 215840 words.
#     The file little_women.txt has about 195624 words.
