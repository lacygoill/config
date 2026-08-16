# Purpose: Make a class called User.   Create two attributes called `first_name`
# and `last_name`, and  then create several other attributes  that are typically
# stored  in  a user  profile.   Make  a  method called  `describe_user()`  that
# prints  a summary  of  the  user's information.   Make  another method  called
# `greet_user()`  that  prints a  personalized  greeting  to the  user.   Create
# several instances representing different users, and call both methods for each
# user.
#
# Reference: page 162 (paper) / 200 (ebook)

class User:
    def __init__(self, first_name, last_name, age, sex):
        self.first_name = first_name
        self.last_name = last_name
        self.age = age
        self.sex = sex

    def describe_user(self):
        long_name = f'{self.first_name} {self.last_name}'
        print(f'{long_name.title()} is {self.age}'
              f' years old, and is a {self.sex}.')

    def greet_user(self):
        long_name = f'{self.first_name} {self.last_name}'
        print(f'Hello, {long_name.title()}!'
              '  How are you today?')

user1 = User('Adem', 'Brock', 34, 'male')
user2 = User('Tina', 'Blaese', 56, 'female')
user3 = User('Olivier', 'Reeves', 78, 'male')

user1.describe_user()
user2.describe_user()
user3.describe_user()
#     Adem Brock is 34 years old, and is a male.
#     Tina Blaese is 56 years old, and is a female.
#     Olivier Reeves is 78 years old, and is a male.

user1.greet_user()
user2.greet_user()
user3.greet_user()
#     Hello, Adem Brock!  How are you today?
#     Hello, Tina Blaese!  How are you today?
#     Hello, Olivier Reeves!  How are you today?
