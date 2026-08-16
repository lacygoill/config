# Files in this directory are ignored!

Make sure the permissions of the directory are correctly set to 0700:

    $ stat --format='%a %n' ~/.ssh
    700 /home/user/.ssh
    ^^^
