# Purpose: A buffet-style restaurant offers only five basic foods.
# Think of five simple foods, and store them in a tuple.
#
#    - Use a `for` loop to print each food the restaurant offers.
#
#    - Try to modify one of the items, and make sure that Python rejects the change.
#
#    - The restaurant changes its menu, replacing two of the items with
#      different foods.  Add a line that rewrites the tuple, and then use
#      a `for` loop to print each of the items on the revised menu.

# Reference: page 68 (paper) / 106 (ebook)

foods = ('potato chips', 'donuts', 'ice cream', 'soda', 'pizza')
for food in foods:
    print(food)
#     potato chips
#     donuts
#     ice cream
#     soda
#     pizza

#     foods[2] = 'french fries'
#     TypeError: 'tuple' object does not support item assignment˜

print()
foods = ('chicken tenders', 'donuts', 'french fries', 'soda', 'pizza')
for food in foods:
    print(food)
#     chicken tenders
#     donuts
#     french fries
#     soda
#     pizza
