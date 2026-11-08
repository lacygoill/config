# Purpose: One common  problem when  prompting for  numerical input  occurs when
# people provide text  instead of numbers.  When you `try`  to convert the input
# to an `int`, you'll get a `ValueError`.   Write a program that prompts for two
# numbers.  Add them  together and print the result.  Catch  the `ValueError` if
# either input value is not a number,  and print a friendly error message.  Test
# your program by entering two numbers and then by entering some text instead of
# a number.
#
# Reference: page 200 (paper) / 238 (ebook)

print("Give me two numbers, and I'll add them.")

first = input('First number: ')
second = input('Second number: ')
try:
    print(int(first) + int(second))
except ValueError:
    print('Please, only input numbers.')

#     Give me two numbers, and I'll add them.
#     First number: 3
#     Second number: 5
#     8

#     First number: a
#     Second number: 5
#     Please, only input numbers.
