# Purpose: Import the `ElectricCar` class, and make an electric car.
# Reference: page 176 (paper) / 214 (ebook)

from car2 import ElectricCar

my_leaf = ElectricCar('nissan', 'leaf', 2024)

print(my_leaf.get_descriptive_name())
my_leaf.battery.describe_battery()
my_leaf.battery.get_range()
#     2024 Nissan Leaf
#     This car has a 40-kWh battery.
#     This car can go about 150 miles on a full charge.
