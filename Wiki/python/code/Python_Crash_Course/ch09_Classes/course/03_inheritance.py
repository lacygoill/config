# Purpose: create a child class which inherits any or all of the attributes of a
# parent class
#
# Reference: page 167 (paper) / 205 (ebook)

class Car: #{{{1
    """A simple attempt to represent a car."""
    def __init__(self, make, model, year):
        """Initialize attributes to describe a car."""
        self.make = make
        self.model = model
        self.year = year
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
# }}}1

# The  parent class  definition must  appear  in the  same file  and before  the
# child's  definition.   The name  of  the  parent  class  must be  included  in
# parentheses in the definition of a child class.
#                v---v
class ElectricCar(Car):
    """Represents aspects of a car, specific to electric vehicles."""

    def __init__(self, make, model, year):
        """
        Initialize attributes of the parent class.
        Then initialize attributes specific to an electric car.
        """
        # The `super()` function is a special function that allows you to call a
        # method from  the parent  class.  This  line tells  Python to  call the
        # `__init__()` method from `Car`,  which gives an `ElectricCar` instance
        # all the  attributes and methods of  a `Car` object.  The  name "super"
        # comes from a convention of calling the parent class a "superclass" and
        # the child class a "subclass".
        # ----v
        super().__init__(make, model, year)

        # We add a  new attribute `self.battery_size` and set  its initial value
        # to 40.  This  attribute will be associated with  all instances created
        # from  the  `ElectricCar`  class  but  won't  be  associated  with  any
        # instances of `Car`.
        self.battery_size = 40


    # We also add  a method called `describe_battery()`  that prints information
    # about the battery.  When we call this method, we get a description that is
    # clearly specific to an electric car:
    def describe_battery(self):
        """Print a statement describing the battery size."""
        print(f'This car has a {self.battery_size}-kWh battery.')

    # You can override any method from `Car`  by defining a method with the same
    # name here.

my_leaf = ElectricCar('nissan', 'leaf', 2024)
print(my_leaf.get_descriptive_name())
#     2024 Nissan Leaf
my_leaf.describe_battery()
#     This car has a 40-kWh battery.
