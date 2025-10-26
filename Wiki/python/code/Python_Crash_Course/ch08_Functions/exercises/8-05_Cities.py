# Purpose: Write a function called `describe_city()`  that accepts the name of a
# city and  its country.  The function  should print a simple  sentence, such as
# "Reykjavik  is in  Iceland".  Give  the parameter  for the  country a  default
# value.  Call your  function for three different cities, at  least one of which
# is not in the default country.

# Reference: page 137 (paper) / 175 (ebook)

def describe_city(city, country='Iceland'):
    print(f'{city} is in {country}.')

describe_city('Reykjavik')
describe_city('Berlin', 'Germany')
describe_city('London', 'England')
#     Reykjavik is in Iceland.
#     Berlin is in Germany.
#     London is in England.
