# Purpose: Add  an  attribute  called  `login_attempts`  to  your  `User`  class
# from Exercise  9-3.  Write  a method called  `increment_login_attempts()` that
# increments the  value of `login_attempts`  by 1.  Write another  method called
# `reset_login_attempts()` that resets the value of `login_attempts` to 0.  Make
# an instance of the `User`  class and call `increment_login_attempts()` several
# times.  Print  the value of `login_attempts`  to make sure it  was incremented
# properly,  and  then  call `reset_login_attempts()`.   Print  `login_attempts`
# again to make sure it was reset to 0.
#
# Reference: page 167 (paper) / 205 (ebook)

class User:
    #                                                   v------------v
    def __init__(self, first_name, last_name, age, sex, login_attempts):
        self.first_name = first_name
        self.last_name = last_name
        self.age = age
        self.sex = sex
        self.login_attempts = login_attempts
        # ---------------------------------^

    def describe_user(self):
        long_name = f'{self.first_name} {self.last_name}'
        print(f'{long_name.title()} is {self.age}'
              f' years old, and is a {self.sex}.')

    def greet_user(self):
        long_name = f'{self.first_name} {self.last_name}'
        print(f'Hello, {long_name.title()}!'
              '  How are you today?')

    # --------------------------------v
    def increment_login_attempts(self):
        self.login_attempts += 1

    # ----------------------------v
    def reset_login_attempts(self):
        self.login_attempts = 0

some_user = User('Adem', 'Brock', 34, 'male', 0)
some_user.increment_login_attempts()
some_user.increment_login_attempts()
some_user.increment_login_attempts()
print(some_user.login_attempts)
#     3

some_user.reset_login_attempts()
print(some_user.login_attempts)
#     0
