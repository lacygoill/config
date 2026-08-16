class Restaurant:
    def __init__(self, restaurant_name, cuisine_type):
        self.name = restaurant_name
        self.type = cuisine_type

    def describe_restaurant(self):
        print(f'The name of the restaurant is {self.name}.')
        print(f'The type of cuisine is {self.type}.')

    def open_restaurant(self):
        print('The restaurant is open.')
