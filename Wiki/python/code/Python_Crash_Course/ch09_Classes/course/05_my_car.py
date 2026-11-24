# Purpose: Import the `Car` class and create an instance from it.
# Reference: page 174 (paper) / 212 (ebook)

from car1 import Car

my_new_car = Car('audi', 'a4', 2024)
print(my_new_car.get_descriptive_name())
#     2024 Audi A4

my_new_car.odometer_reading = 23
my_new_car.read_odometer()
#     This car has 23 miles on it.
