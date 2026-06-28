# Purpose: Write a  while loop that prompts  users for their name.   Collect all
# the  names that  are entered,  and then  write these  names to  a file  called
# `guest_book.txt`.  Make sure each entry appears on a new line in the file.
#
# Reference: page 192 (paper) / 230 (ebook)

from pathlib import Path

path = Path('guest_book.txt')

contents = ''
while True:
    name = input('What is your name? ')
    if not name:
        break
    contents += name + '\n'

path.write_text(contents)
