# Purpose: An administrator  is a special  kind of  user.  Write a  class called
# `Admin`  that inherits  from the  `User` class  you wrote  in Exercise  9-3 or
# Exercise 9-5.  Add  an attribute, `privileges`, that stores a  list of strings
# like "can add  post", "can delete post",  "can ban user", and so  on.  Write a
# method  called  `show_privileges()`  that  lists the  administrator's  set  of
# privileges.  Create an instance of `Admin`, and call your method.
#
# Reference: page 173 (paper) / 211 (ebook)

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

class Admin(User):
    def __init__(self, first_name, last_name, age, sex):
        super().__init__(first_name, last_name, age, sex)
        self.privileges = ['can add post', 'can delete post', 'can ban user']

    def show_privileges(self):
        print('An admin:')
        for privilege in self.privileges:
            print(' - ' + privilege)

admin = Admin('Adem', 'Brock', 34, 'male')
admin.show_privileges()
#     An admin:
#      - can add post
#      - can delete post
#      - can ban user
