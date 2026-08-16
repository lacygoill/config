# Purpose: Import a module into a module.
# Reference: page 177 (paper) / 215 (ebook)

"""A set of classes that can be used to represent electric cars."""

from car1 import Car

class Battery: #{{{1
# We  define a  new class  called Battery  that doesn't  inherit from  any other
# class.

    """A simple attempt to model a battery for an electric car."""

    # The `__init__()` method has one  parameter, `battery_size`, in addition to
    # `self`.  This is an optional parameter  that sets the battery's size to 40
    # if no value is provided.
    def __init__(self, battery_size=40):
        """Initialize the battery's attributes."""
        self.battery_size = battery_size

    # The method `describe_battery()` has been moved to this class as well.
    def describe_battery(self):
        """Print a statement describing the battery size."""
        print(f'This car has a {self.battery_size}-kWh battery.')

    def get_range(self):
        """Print a statement about the range this battery provides."""
        if self.battery_size == 40:
            range = 150
        elif self.battery_size == 65:
            range = 225

        print(rf'This car can go about {range} miles on a full charge.')

class ElectricCar(Car): #{{{1
    """Represents aspects of a car, specific to electric vehicles."""
    def __init__(self, make, model, year):
        """
        Initialize attributes of the parent class.
        Then initialize attributes specific to an electric car.
        """
        super().__init__(make, model, year)
        # We add  an attribute called  `self.battery` to  which we assign  a new
        # instance of  `Battery` (with a default  size of 40, because  we're not
        # specifying a value).
        self.battery = Battery()
#}}}1
