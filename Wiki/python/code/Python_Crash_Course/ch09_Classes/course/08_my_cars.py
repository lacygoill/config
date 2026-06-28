# Purpose: Import entire module containing classes.
# Reference: page 176 (paper) / 214 (ebook)

import car

my_mustang = car.Car('ford', 'mustang', 2024)
print(my_mustang.get_descriptive_name())
#     2024 Ford Mustang

my_leaf = car.ElectricCar('nissan', 'leaf', 2024)
print(my_leaf.get_descriptive_name())
#     2024 Nissan Leaf
