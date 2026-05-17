# Purpose: Make a dictionary called `favorite_places`.   Think of three names to
# use as keys in the dictionary, and store one to three favorite places for each
# person.  Loop through  the dictionary, and print each person's  name and their
# favorite places.

# Reference: page 112 (paper) / 150 (ebook)

favorite_places = {
    'john': ['berlin'],
    'alice': ['hong kong', 'paris'],
    'bob': ['new york', 'madrid', 'rome'],
}

for name, places in favorite_places.items():
    if len(places) == 1:
        print(f"{name.title()}'s favorite place is {places[0].title()}.")
        print()
    else:
        print(f"{name.title()}'s favorite places are:")
        for place in places:
            print('\t' + '- ' + place.title())
        print()
#     John's favorite place is Berlin.
#
#     Alice's favorite places are:
#         - Hong Kong
#         - Paris
#
#     Bob's favorite places are:
#         - New York
#         - Madrid
#         - Rome
