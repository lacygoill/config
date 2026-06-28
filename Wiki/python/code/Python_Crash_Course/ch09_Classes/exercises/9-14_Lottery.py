# Purpose: Make a list or tuple containing a series of 10 numbers and 5 letters.
# Randomly select 4 numbers or letters from  the list and print a message saying
# that any ticket matching these 4 numbers or letters wins a prize.
#
# Reference: page 180 (paper) / 218 (ebook)

from random import randint
my_list = ['a', 'b', 'c', 'd', 'e'] + list(range(1, 11))

results = []
for i in range(4):
    rand = randint(0, len(my_list) - 1)
    if isinstance(my_list[rand], int):
        results += [str(my_list[rand])]
    else:
        results += [my_list[rand]]

print('Any ticket matching these 4 numbers or letters wins a prize: '
      + ', '.join(results))
#     Any ticket matching these 4 numbers or letters wins a prize: 8, b, 6, e
