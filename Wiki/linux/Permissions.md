# File Permissions
## Which user/group is given to a newly created file/directory?

The FSUID/FSGID (FileSystem User/Group ID) of the creating process:

   > grpid|bsdgroups and nogrpid|sysvgroups
   >        These  options  define  what group id a newly created file gets.
   >        When grpid is set, it takes the group id  of  the  directory  in
   >        which  it is created; otherwise **(the default) it takes the fsgid**
   >        **of the current process**, unless the directory has the setgid  bit
   >        set,  in  which case it takes the gid from the parent directory,
   >        and also gets the setgid bit set if it is a directory itself.

Source: `man 5 ext4 /Mount options for ext2/;/grpid`

In practice, those seem to be identical to the EUID and EGID:

    $ cd /tmp
    $ cp /usr/bin/sleep .
    $ sudo chown nobody:nogroup ./sleep
    $ sudo chmod u+s,g+s ./sleep
    $ ./sleep 60
    # press C-z to suspend sleep(1)

                          v--v v---v
    $ ps -e --format=comm,euid,fsuid | grep sleep
    sleep 65534 65534
          ^---^ ^---^

                          v--v v---v
    $ ps -e --format=comm,egid,fsgid | grep sleep
    sleep 65534 65534
          ^---^ ^---^

Exception: A  newly created  file/directory  inherits its  GID  from its  parent
directory if the latter has the setgid bit set.

##
## On which condition can a user
### change the permissions of a file/directory?

They must own it.

---

That's the only condition.  They don't need any other permission.

    $ touch file
    $ chmod a= file
    $ sudo chown $USER:nogroup file
                 ^---^

    $ chmod a=rwx file
    # no error is given

### list the contents of a directory?

They must have read permission on it.

    $ mkdir dir
    $ touch dir/file
    $ chmod a= dir/file
    $ chmod a=,o=r dir
                 ^
    $ sudo chown nobody:nogroup dir{,/file}

    $ ls -l dir
    ls: cannot access 'dir/file': Permission denied
    total 0
    -????????? ? ? ? ?            ? file

Here, an  error is given  because `stat(2)` fails when  `ls(1)` calls it  to get
`dir/file`'s information:

   > No permissions are required on the file itself, but—in the case of stat(),
   > fstatat(), and lstat()—**execute (search) permission is required on all of the**
   > **directories in pathname that lead to the file.**

Source: `man 2 stat /DESCRIPTION/;/permissions`

Nonetheless, `file` is still correctly listed.
To suppress the error, you also need execute permission on `dir/`:

    $ sudo chmod o=rx dir
                    ^
    $ ls -l dir
    total 0
    ---------- 1 nobody nogroup ... file

### enter a directory?

They must have read and execute permissions on it.

    $ mkdir dir
    $ chmod a=,o=rx dir
                 ^^
    $ sudo chown nobody:nogroup dir

    $ cd dir
    # no error is given

### move a file/directory?

They must have write and execute permissions on the parent directory/directories.

    $ mkdir dir
    $ touch dir/file
    $ chmod a= dir/file
    $ chmod a=,o=wx dir
                 ^^
    $ sudo chown nobody:nogroup dir{,/file}

    $ mv dir/{file,renamed}
    # no error is given

##
## Why can't I write a file that I created, after `$ chmod u-w,g+w`, even though I'm in its group?

    $ touch file
    $ chmod u-w,g+w file
    $ echo >file
    warning: An error occurred while redirecting file 'file'
    open: Permission denied

You're the owner of  `file`.  As such, the only permissions  that matter are the
ones specific to the owner.  And the owner does not have the permission to write
the file.

## Why do `$ chmod -w` and `$ chmod +w` fail to clear/set the world-writable bit of a file?

If you  don't specify which users'  access is to be  changed, `chmod(1)` changes
all users' accesses, but bits that are set in the umask are not affected:

   > A  combination  of the letters ugoa controls which users' access to the
   > file will be changed: the user who owns it  (u),  other  users  in  the
   > file's group (g), other users not in the file's group (o), or all users
   > (a).  If none of these are given, the effect is as if (a)  were  given,
   > but **bits that are set in the umask are not affected**.

Source: `man chmod /umask`

And the world-writable bit is always in the umask (the latter is either `002` or
`022`).

If you  really want to  clear/set the world-writable  bit for everybody,  do not
omit the users part of the symbolic modes; instead, specify `a` explicitly:

            v
    $ chmod a+w file
    $ chmod a-w file
            ^

##
## How to shorten symbolic modes in a `chmod(1)` command?

If  you  need to  set  different  permissions  to  different entities,  you  can
concatenate the operations with commas:

    g+r
    o-w
    ⇔
    g+r,o-w
       ^

If  you  need  to set  the  same  permissions  to  different entities,  you  can
concatenate the latters:

    v   v
    g+r,o+r
    ⇔
    go+r
    ^^

If you  need to  set different permissions  to the same  entities, you  can also
concatenate the operations (without commas):

      vv   vv   vv
    go+r,go+X,go-w
    ⇔
      vvv
    go+rX-w
         ^^

## How to mix symbolic and numeric modes in the same `chmod(1)` command?

Prefix the numeric  mode with an operator  (`+`, `-`, or `=`),  and separate the
modes with commas.  For example:

    $ chmod =0,u+r file
            ^
            you cannot omit the operator in this case

This clears all  permissions except for enabling read permission  for the file's
owner.

##
# Pitfalls
## I can't write some file even though I have the permission to do it!

Make sure the filesystem is not mounted as read-only:

    $ findmnt --noheadings --output=OPTIONS -- "$(df --output=target . | grep '^/')"
    # "ro" should NOT be listed among the mount options

Otherwise,  maybe  the file  has  been  given  some  attribute specific  to  the
filesystem  it lives  on  (e.g. access  control lists  (ACLs)  or the  immutable
attribute).  These  are usually  set using programs  specific to  the filesystem
(e.g. `chattr(1)` for `ext2`).

## I can't execute some file even though I have the permission to do it!

Make sure the filesystem is not mounted with the `noexec` option:

    $ findmnt --noheadings --output=OPTIONS -- "$(df --output=target . | grep '^/')" | grep noexec

MRE:

    $ cd /run
    $ sudo cp /usr/bin/sleep .
    $ ./sleep 60
    fish: Unknown command. './sleep' exists but is not an executable file.
    ✘

    $ findmnt --noheadings --output=OPTIONS -- "$(df --output=target . | grep '^/')"
    rw,nosuid,nodev,noexec,relatime,size=368568k,mode=755,inode64
                    ^----^
                      ✘

## Linux ignores the setuid of my file!

Make sure the filesystem is not mounted with the `nosuid` option:

    $ findmnt --noheadings --output=OPTIONS -- "$(df --output=target . | grep '^/')" | grep nosuid

The latter  is a  protection measure that  wipes any setuid  or setgid  bit from
programs stored on the filesystem.

MRE:

    $ cd /run/user/$UID
    $ cp /usr/bin/sleep .
    $ sudo chown root:root ./sleep
    $ sudo chmod u+s ./sleep
    $ ./sleep 60

    $ ps -e --format=pid,comm,ruser,euser | grep sleep
    1234 sleep lgc lgc
                   ^^^
                    ✘
                   it should be "root"

    $ findmnt --noheadings --output=OPTIONS -- "$(df --output=target . | grep '^/')"
    rw,nosuid,nodev,relatime,size=368564k,mode=700,uid=1000,gid=1000,inode64
       ^----^
         ✘

## `chmod(1)` does not clear the setgid of my directory!

                          v               v
    $ mkdir -p dir; chmod 7777 dir; chmod 0777 dir; stat --format='%a %A %n' dir
    6777 drwsrwsrwx dir
    ^
    ✘
    should be 0

Prepend an extra `0`:

                          v               vv
    $ mkdir -p dir; chmod 7777 dir; chmod 00777 dir; stat --format='%a %A %n' dir
    777 drwxrwxrwx dir
    ^^^
     ✔

Note that the first  digit of a five-digits mode must always  be `0`; the second
digit, which encodes the desired special bits, can be any number between `0` and
`7`.  Also, this pitfall is limited to directories; not to files:

                        v                v
    $ touch file; chmod 7777 file; chmod 0777 file; stat --format='%a %A %n' file
    777 -rwxrwxrwx file
    ^^^
     ✔

---

On most  systems, if  a directory's  setgid bit is  set, newly  created subfiles
inherit  the same  group  as  the directory,  and  newly created  subdirectories
inherit the setgid bit of the parent directory.  This mechanism lets users share
files more  easily, by  lessening the  need to use  `chmod(1)` or  `chown(1)` to
share new files.

This  convenience mechanism  relies  on the  setgid bit  of  directories.  If  a
command like `chmod(1)` routinely cleared this bit on directories, the mechanism
would be  less convenient  and it  would be harder  to share  files.  Therefore,
`chmod(1)` does  not affect the  setgid bit of a  directory (nor the  setuid bit
(*)) unless the user:

   - specifically mentions them in a symbolic mode
   - uses an operator followed by a numeric mode (e.g. `=755`)
   - sets them in a numeric mode
   - clears them in a numeric mode that has five octal digits

(*)  On some  systems, a  directory's setuid  bit has  a similar  effect on  the
ownership of new subfiles and the setuid bit of new subdirectories.
