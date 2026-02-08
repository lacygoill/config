# Purpose: Start with  your work from  Exercise 9-8.  Store the  classes `User`,
# `Privileges`, and  `Admin` in  one module.   Create a  separate file,  make an
# `Admin`  instance, and  call `show_privileges()`  to show  that everything  is
# working correctly.
#
# Reference: page 179 (paper) / 217 (ebook)

import user_admin_privileges as uap

admin = uap.Admin('Adem', 'Brock', 34, 'male')
admin.privileges.show_privileges()
#     An admin:
#      - can add post
#      - can delete post
#      - can ban user
