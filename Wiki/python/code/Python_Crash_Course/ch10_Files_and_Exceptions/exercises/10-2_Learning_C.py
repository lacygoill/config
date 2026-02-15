# Purpose: Learning C.
#
# You can  use the `replace()`  method to  replace any word  in a string  with a
# different word.   Here's a  quick example  showing how  to replace  'dog' with
# 'cat' in a sentence:
#
#     >>> message = "I really like dogs."
#     >>> message.replace('dog', 'cat')
#     'I really like cats.'
#
# Read in  each line from  the file  you just created,  learning_python.txt, and
# replace the word Python  with the name of another language,  such as C.  Print
# each modified line to the screen.
#
# Reference: page 189 (paper) / 227 (ebook)


from pathlib import Path

path = Path('learning_python.txt')
contents = path.read_text()

for line in contents.splitlines():
    print(line.replace('Python', 'C'))
    #     In C, you can create a list by placing comma-separated values inside square brackets.
    #     In C, you can define functions using the def keyword followed by the function name and parameters.
    #     In C, you can import modules to access additional functionality with the import statement.

