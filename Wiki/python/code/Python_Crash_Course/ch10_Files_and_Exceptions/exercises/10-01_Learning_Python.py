# Purpose: Open  a  blank  file in  your  text  editor  and  write a  few  lines
# summarizing what you've learned about Python so far.  Start each line with the
# phrase "In  Python you can".   Save the  file as `learning_python.txt`  in the
# same directory  as your  exercises from  this chapter.   Write a  program that
# reads the file and prints what you wrote two times: print the contents once by
# reading in the entire  file, and once by storing the lines in  a list and then
# looping over each line.
#
# Reference: page 189 (paper) / 227 (ebook)

from pathlib import Path

path = Path('learning_python.txt')

contents = path.read_text().rstrip()
print(contents)
#     In Python, you can create a list by placing comma-separated values inside square brackets.
#     In Python, you can define functions using the def keyword followed by the function name and parameters.
#     In Python, you can import modules to access additional functionality with the import statement.

contents = path.read_text()
for line in contents.splitlines():
    print(line)
#     In Python, you can create a list by placing comma-separated values inside square brackets.
#     In Python, you can define functions using the def keyword followed by the function name and parameters.
#     In Python, you can import modules to access additional functionality with the import statement.


