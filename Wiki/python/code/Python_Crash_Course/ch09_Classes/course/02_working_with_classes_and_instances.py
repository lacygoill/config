# Purpose: Working with Classes and Instances
# Reference: page 162 (paper) / 200 (ebook)

class Car:
    """A simple attempt to represent a car."""

    def __init__(self, make, model, year):
        """Initialize attributes to describe a car."""
        self.make = make
        self.model = model
        self.year = year
        # When an instance  is created, attributes can be  defined without being
        # passed  in as  parameters.  These  attributes  can be  defined in  the
        # `__init__()` method, where  they are assigned a  default value.  Here,
        # we assign 0 to the `odometer_reading` attribute.
        self.odometer_reading = 0

    def get_descriptive_name(self):
        """Return a neatly formatted descriptive name."""
        long_name = f'{self.year} {self.make} {self.model}'
        return long_name.title()

    def read_odometer(self):
        """Print a statement showing the car's mileage."""
        print(f'This car has {self.odometer_reading} miles on it.')

    def update_odometer(self, mileage):
        """
        Set the odometer reading to the given value.
        Reject the change if it attempts to roll the odometer back.
        """
        if mileage >= self.odometer_reading:
            self.odometer_reading = mileage
        else:
            print("You can't roll back an odometer!")

    def increment_odometer(self, miles):
        """Add the given amount to the odometer reading."""
        self.odometer_reading += miles

my_new_car = Car('audi', 'a4', 2024)
print(my_new_car.get_descriptive_name())
#     2024 Audi A4
my_new_car.read_odometer()
#     This car has 0 miles on it.

# Updating an attribute directly. {{{1
#
# The  simplest way  to  modify the  value  of  an attribute  is  to access  the
# attribute directly through  an instance.  Here we set the  odometer reading to
# `23` directly:
my_new_car.odometer_reading = 23
my_new_car.read_odometer()
#     This car has 23 miles on it.

# Updating an attribute using a method. {{{1

# We  can also  modify an  attribute using  a method  that handles  the updating
# internally:
my_new_car.update_odometer(45)
my_new_car.read_odometer()
#     This car has 45 miles on it.

# Incrementing an attribute's value through a method. {{{1

my_used_car = Car('subaru', 'outback', 2019)
print(my_used_car.get_descriptive_name())
#     2019 Subaru Outback

my_used_car.update_odometer(23_500)
my_used_car.read_odometer()
#     This car has 23500 miles on it.

my_used_car.increment_odometer(100)
my_used_car.read_odometer()
#     This car has 23600 miles on it.
