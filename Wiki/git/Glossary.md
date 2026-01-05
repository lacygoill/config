# a
## author

Person who originally wrote a patch which was then later applied and committed.

The author might not be the same person as the committer.
The committer is the person who last applied the patch.

##
# f
## committed/unmodified file

A file which is safely stored in `.git/`.

## modified file

A file which you have changed since  it was checked out/committed, but which you
haven't staged/committed yet.

## staged file

A file which you  have changed (or a new untracked file), and  marked to go into
the next commit, in its current version, by adding it to the index.

## untracked file

A file which was not in the last commit and is not in the index.

##
# s
## staging area (aka index)

A file  in `.git/`  that stores  information about  what will  go into  the next
commit.  Its technical name in Git parlance is the “index”.

##
# w
## working tree

A single checkout of one version of the project.
These files are pulled  out of the compressed database in  `.git/` and placed on
disk for you to use or modify.
