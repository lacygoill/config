# Purpose:  Make  two files,  `cats.txt` and `dogs.txt`.   Store at  least three
# names of cats  in the first file and  three names of dogs in  the second file.
# Write a program that  tries to read these files and print  the contents of the
# file to  the screen.   Wrap your  code in  a `try-except`  block to  catch the
# `FileNotFound` error, and print a friendly message if a file is missing.  Move
# one of  the files to a  different location on  your system, and make  sure the
# code in the `except` block executes properly.
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
    print('A file is missing.')
