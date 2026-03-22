# Purpose: Large Files: One Million Digits
# Reference: page 188 (paper) / 226 (ebook)

from pathlib import Path

path = Path('pi_million_digits.txt')

pi_string = ''
for line in path.read_text().splitlines():
    pi_string += line.lstrip()

print(f'{pi_string[:52]}...')
print(len(pi_string))
#     3.14159265358979323846264338327950288419716939937510...
#     1000002
