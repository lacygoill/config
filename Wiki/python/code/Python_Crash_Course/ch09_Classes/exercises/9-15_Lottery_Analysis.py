# Purpose: You can  use a loop to  see how hard it  might be to win  the kind of
# lottery you just  modeled.  Make a list or tuple  called `my_ticket`.  Write a
# loop  that keeps  pulling numbers  until your  ticket wins.   Print a  message
# reporting how many times the loop had to run to give you a winning ticket.
#
# Reference: page 180 (paper) / 218 (ebook)

from random import randint
my_list = ['a', 'b', 'c', 'd', 'e'] + list(range(1, 11))
my_ticket = [8, 'b', 6, 'e']

j = 0
while True:
    results = []
    for i in range(4):
        rand = randint(0, len(my_list) - 1)
        results += [my_list[rand]]
    j += 1
    if results == my_ticket:
        print(f'The loop had to run {j} times to give you a winning ticket.')
        break

#     The loop had to run 24982 times to give you a winning ticket.
