# Purpose: Accessing a file's lines.
# Reference: page 186 (paper) / 224 (ebook)

from pathlib import Path

path = Path('pi_digits.txt')

for line in path.read_text().splitlines():
    print(line)
    #     3.1415926535
    #       8979323846
    #       2643383279
