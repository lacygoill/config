# Purpose: Concatenate lines into a single string.
# Reference: page 187 (paper) / 225 (ebook)

from pathlib import Path

path = Path('pi_digits.txt')

pi_string = ''
for line in path.read_text().splitlines():
    pi_string += line.lstrip()
print(pi_string)
