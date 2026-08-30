# Purpose: Import multiple classes from module.
# Reference: page 176 (paper) / 214 (ebook)

from car2 import Car, ElectricCar

my_mustang = Car('ford', 'mustang', 2024)
print(my_mustang.get_descriptive_name())
#     2024 Ford Mustang

my_leaf = Car('nissan', 'leaf', 2024)
print(my_leaf.get_descriptive_name())
#     2024 Nissan Leaf
