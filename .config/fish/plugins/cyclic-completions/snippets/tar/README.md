# How to extract only some files out of an archive?

Specify their names at the end of the command-line.

This assumes that you know their exact names (which you can get with `--list`).

##
# In general, why should I avoid absolute paths for the files/directories that I want to archive?

`tar(1)` would remove the leading slash:

                                                v
    $ tar --create --file=archive.tar --verbose /path/to/node
    tar: Removing leading `/' from member names
    ^-----------------------------------------^

That's  because it  assumes that  in the  general case,  the user  will want  to
extract the  archive relative to the  CWD.  Only specify relative  paths, and if
necessary use `--directory` to change `tar(1)`'s CWD.

## When do they still make sense?

When the files/directories are meant to be extracted at a specific location.

For example, if you archive some config  files from under `/etc`, you'll need to
extract  them under  `/etc` and  not anywhere  else, because  that's where  your
programs expect to find them.   In contrast, personal documents (ebooks, photos,
...)  can be  located anywhere  you  want, so  it  makes sense  for `tar(1)`  to
save/restore them relative your CWD.

To use  absolute paths,  pass `--absolute-names` to  `tar(1)` when  creating the
archive,  *and*  when extracting  it.   Alternatively,  pass `--directory=/`  to
`tar(1)`  when extracting  the  archive (or  run `$ cd /`  before),  so that  it
completes relative paths with `/` (its  CWD), rather than with whatever your CWD
happens to be.

##
# `--append`, `--update`

Both options are meant  to change an existing archive by  appending files to it.
However, they  differ when they have  to handle a  file which is already  in the
archive:

   - `--append` appends the file unconditionally
   - `--update` appends the file unless the archive already contains a newer
     version (or a version as old)

---

Usage example:

    # append files newer than a timestamp file
    $ find . -cnewer timestamp -print0 \
        | tar --null --append --file=ARCHIVE.tar --files-from=- --verbose && touch timestamp
                     ^------^

---

Caveat: You can't `--append`/`--update` a compressed archive:

    tar: Cannot update compressed archives

So, forget about `--gzip`.

# `--directory`

This is similar to `git(1)`'s `-C`.  It changes the CWD of `tar(1)`, which later
lets you  specify paths  relative to  a directory  different than  `$PWD`.  More
specifically, it affects where `tar(1)`:

   - looks for files/directories to put into the archive (when you use `--create`)
   - `--extract`s an archive

`--directory` has no effect on paths directly assigned to options (like `--file`
and `--files-from`).  And  it has no effect on where  an archive is `--create`d;
that's the sole  job of `--file`.  For example, suppose  you're in `~/Wiki`, and
want to archive  all its files inside  an archive located in  `/tmp`.  You can't
write this:

    $ cd ~/Wiki
    $ find . -type f -print0 \
        | tar --null --create --directory=/tmp --file=archive.tar --files-from=-
                              ^--------------^
                                     ✘
    tar: ./anki/Glossary.md: Cannot stat: No such file or directory
    ...

Here, `--directory=/tmp` does not mean: "create my archive in /tmp".
It means: "the paths read from STDIN are relative to /tmp".
Which is wrong, because your Wiki files are not under `/tmp`, but under `~/Wiki`.

Instead, you need to correctly set the path assigned to `--file`:

    $ find . -type f -print0 \
        | tar --null --create --file=/tmp/archive.tar --files-from=-
                                     ^---^
                                       ✔

# `--exclude=GLOB`

Use this to exclude files matching a `glob(3)`-style wildcard pattern.

# `--gzip`, `--zstd`

Compress the archive with `gzip(1)` or `zstd(1)`.

# `--wildcards`

Use this to only extract files matching a given glob:

    $ tar --extract --file=ARCHIVE.tar --wildcards '*some*glob*'
                                       ^---------^

And don't put an equal sign after `--wildcards`.  The latter does not expect any
argument; it's a boolean-like option whose presence adds support for globs.

##
# Only relevant when `--extract`ing:
## `--keep-newer-files`

Don't replace existing files that are newer than their archive copies.

## `--keep-old-files`

Don't replace existing files when extracting.

## `--remove-files`

Remove files from disk after adding them to the archive.

## `--skip-old-files`

Don't replace existing files when extracting; silently skip over them.
