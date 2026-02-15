# Purpose: Importing a module into a module.
# Reference: page 178 (paper) / 216 (ebook)

from car1 import Car
from electric_car import ElectricCar

my_mustang = Car('ford', 'mustang', 2024)
print(my_mustang.get_descriptive_name())
#     2024 Ford Mustang

my_leaf = ElectricCar('nissan', 'leaf', 2024)
print(my_leaf.get_descriptive_name())
#     2024 Nissan Leaf
