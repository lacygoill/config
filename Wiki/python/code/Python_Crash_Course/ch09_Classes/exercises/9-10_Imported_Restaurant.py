# Purpose: Using your  latest `Restaurant` class,  store it  in a module.   Make a
# separate file  that imports `Restaurant`. Make  a `Restaurant` instance,  and call
# one  of `Restaurant`'s  methods to  show that  the import  statement is  working
# properly.
#
# Reference: page 179 (paper) / 217 (ebook)

from restaurant import Restaurant

restaurant = Restaurant('La Hache', 'classique')
restaurant.describe_restaurant()
#     The name of the restaurant is La Hache.
#     The type of cuisine is classique.
