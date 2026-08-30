# Purpose: Start  with  your program  from  Exercise  9-1  (page 162).   Add  an
# attribute  called `number_served`  with a  default  value of  `0`.  Create  an
# instance called `restaurant`  from this class.  Print the  number of customers
# the restaurant has served, and then change this value and print it again.
#
# Add a  method called  `set_number_served()` that  lets you  set the  number of
# customers that have been served.  Call this method with a new number and print
# the value again.
#
# Add a  method called `increment_number_served()`  that lets you  increment the
# number of  customers who've been served.   Call this method with  any number
# you like that could represent how many customers were served in, say, a day of
# business.
#
# Reference: page 166 (paper) / 204 (ebook)

class Restaurant:
    def __init__(self, restaurant_name, cuisine_type, number_served):
        self.name = restaurant_name
        self.type = cuisine_type
        self.number_served = number_served

    def describe_restaurant(self):
        print(f'The name of the restaurant is {self.name}.')
        print(f'The type of cuisine is {self.type}.')

    def open_restaurant(self):
        print('The restaurant is open.')

    def set_number_served(self, n):
        self.number_served = n

    def increment_number_served(self, n):
        self.number_served += n

restaurant = Restaurant('La Hache', 'classique', 12)
print(restaurant.number_served)
#     12

restaurant.number_served = 34
print(restaurant.number_served)
#     34

restaurant.set_number_served(56)
print(restaurant.number_served)
#     56

restaurant.increment_number_served(78)
print(restaurant.number_served)
#     134
