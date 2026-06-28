# Purpose: Is your birthday contained in Pi?
# Reference: page 188 (paper) / 226 (ebook)

from pathlib import Path

path = Path('pi_million_digits.txt')

pi_string = ''
for line in path.read_text().splitlines():
    pi_string += line.lstrip()

birthday = input('Enter your birthday, in the form mmddyy: ')
if birthday in pi_string:
    print('Your birthday appears in the first million digits of pi!')
else:
    print('Your birthday does not appear in the first million digits of pi.')
