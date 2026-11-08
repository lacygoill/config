from user import User

class Privileges: #{{{1
    def __init__(self):
        self.privileges = ['can add post', 'can delete post', 'can ban user']

    def show_privileges(self):
        print('An admin:')
        for privilege in self.privileges:
            print(' - ' + privilege)
#}}}1
class Admin(User): #{{{1
    def __init__(self, first_name, last_name, age, sex):
        super().__init__(first_name, last_name, age, sex)
        self.privileges = Privileges()
