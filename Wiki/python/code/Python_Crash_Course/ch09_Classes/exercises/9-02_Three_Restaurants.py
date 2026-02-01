# Purpose: Start  with your  class from  Exercise 9-1.   Create three  different
# instances from the class, and call `describe_restaurant()` for each instance.
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

restaurant1 = Restaurant('Le Tire-Bouchon', 'casual')
restaurant2 = Restaurant('Le Bistrot Des Cocottes', 'modern')
restaurant3 = Restaurant('Le Kuhn', 'unpretentious')

restaurant1.describe_restaurant()
restaurant2.describe_restaurant()
restaurant3.describe_restaurant()
#     The name of the restaurant is Le Tire-Bouchon.
#     The type of cuisine is casual.
#     The name of the restaurant is Le Bistrot Des Cocottes.
#     The type of cuisine is modern.
#     The name of the restaurant is Le Kuhn.
#     The type of cuisine is unpretentious.
