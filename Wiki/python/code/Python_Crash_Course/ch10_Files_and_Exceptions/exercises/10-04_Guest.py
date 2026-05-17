# Purpose: Write a  program that  prompts the  user for  their name.   When they
# respond, write their name to a file called `guest.txt`.
#
# Reference: page 192 (paper) / 230 (ebook)

from pathlib import Path

name = input('What is your name? ')
path = Path('guest.txt')
path.write_text(name)
