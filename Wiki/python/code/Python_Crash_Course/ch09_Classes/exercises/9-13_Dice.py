# Purpose: Make a  class `Die` with  one attribute  called `sides`, which  has a
# default value of  6.  Write a method called `roll_die()`  that prints a random
# number between 1 and the number of sides  the die has.  Make a 6-sided die and
# roll it 10 times.   Make a 10-sided die and a 20-sided die.   Roll each die 10
# times.
#
# Reference: page 180 (paper) / 218 (ebook)

from random import randint

class Die:
    def __init__(self, sides=6):
        self.sides = sides

    def roll_die(self):
        print(randint(1, self.sides))

# create a 6-sides `die` instance
die = Die()
# roll it 10 times
for i in range(10):
    die.roll_die()
    #     3
    #     6
    #     6
    #     6
    #     2
    #     6
    #     4
    #     3
    #     2
    #     2

# create a 10-sides `die` instance
die = Die(10)
# roll it 10 times
for i in range(10):
    die.roll_die()
    #     2
    #     5
    #     6
    #     9
    #     6
    #     2
    #     5
    #     7
    #     5
    #     6

# create a 20-sides `die` instance
die = Die(20)
# roll it 10 times
for i in range(10):
    die.roll_die()
    #     2
    #     2
    #     4
    #     18
    #     19
    #     1
    #     1
    #     7
    #     11
    #     5
