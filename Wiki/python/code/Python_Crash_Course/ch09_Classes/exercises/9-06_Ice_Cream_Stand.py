# Purpose: An ice cream  stand is a specific kind of  restaurant.  Write a class
# called `IceCreamStand` that inherits from  the `Restaurant` class you wrote in
# Exercise 9-1  or Exercise 9-4.   Either version of  the class will  work; just
# pick the one you like better.  Add an attribute called `flavors` that stores a
# list  of ice  cream  flavors.  Write  a method  that  displays these  flavors.
# Create an instance of `IceCreamStand`, and call this method.
#
# Reference: page 173 (paper) / 211 (ebook)

class Restaurant:
    def __init__(self, restaurant_name, cuisine_type):
        self.name = restaurant_name
        self.type = cuisine_type

    def describe_restaurant(self):
        print(f'The name of the restaurant is {self.name}.')
        print(f'The type of cuisine is {self.type}.')

    def open_restaurant(self):
        print('The restaurant is open.')

class IceCreamStand(Restaurant):
    def __init__(self):
        """Initialize attributes of the parent class."""
        super().__init__('La Hache', 'classique')
        self.flavors = ['chocolate', 'strawberry', 'vanilla']

    def display_flavors(self):
        flavors = ', '.join(self.flavors)
        print(f'The restaurant offers {len(self.flavors)}'
              ' types of ice creams: {flavors}.')

ice_cream_restaurant = IceCreamStand()
ice_cream_restaurant.display_flavors()
#     The restaurant offers 3 types of ice creams: {flavors}.
