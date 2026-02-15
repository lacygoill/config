class User: #{{{1
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

class Admin(User): #{{{1
    def __init__(self, first_name, last_name, age, sex):
        super().__init__(first_name, last_name, age, sex)
        self.privileges = Privileges()

class Privileges: #{{{1
    def __init__(self):
        self.privileges = ['can add post', 'can delete post', 'can ban user']

    def show_privileges(self):
        print('An admin:')
        for privilege in self.privileges:
            print(' - ' + privilege)
#}}}1
