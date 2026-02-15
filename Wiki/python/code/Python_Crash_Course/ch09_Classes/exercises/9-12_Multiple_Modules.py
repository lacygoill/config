# Purpose: Store the `User` class in one  module, and store the `Privileges` and
# `Admin` classes in  a separate module.  In a separate  file, create an `Admin`
# instance and call `show_privileges()` to show that everything is still working
# correctly.
#
# Reference: page 179 (paper) / 217 (ebook)

from admin_privileges import Admin

admin = Admin('Adem', 'Brock', 34, 'male')
admin.privileges.show_privileges()
#     An admin:
#      - can add post
#      - can delete post
#      - can ban user
