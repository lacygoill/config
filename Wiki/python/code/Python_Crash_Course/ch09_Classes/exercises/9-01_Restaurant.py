# Purpose: Make  a  class  called  `Restaurant`.  The  `__init__()`  method  for
# `Restaurant`  should   store  two   attributes:  a  `restaurant_name`   and  a
# `cuisine_type`.   Make a  method  called  `describe_restaurant()` that  prints
# these two pieces of information,  and a method called `open_restaurant()` that
# prints a  message indicating that  the restaurant  is open.  Make  an instance
# called `restaurant` from  your class.  Print the  two attributes individually,
# and then call both methods.
#
# Reference: page 162 (paper) / 200 (ebook)

class Restaurant:
    def __init__(self, restaurant_name, cuisine_type):
        self.name = restaurant_name
        self.type = cuisine_type

    def describe_restaurant(self):
        print(f'The name of the restaurant is {self.name}.')
        print(f'The type of cuisine is {self.type}.')

    def open_restaurant(self):
        print('The restaurant is open.')

restaurant = Restaurant('La Hache', 'classique')
print(restaurant.name)
print(restaurant.type)
#     La Hache
#     classique

restaurant.describe_restaurant()
restaurant.open_restaurant()
#     The name of the restaurant is La Hache.
#     The type of cuisine is classique.
#     The restaurant is open.
