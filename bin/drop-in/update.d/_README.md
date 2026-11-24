See also `~/.config/navi/snippets/compile.cheat`

# How to make a compilation faster?

Use more cores:

    $ make -j2
             ^
             start 2 jobs in parallel

To find out how many cores your processor has:

    $ lscpu | grep '^CPU(s):'
    CPU(s):                          4

# How to control where `$ make install` copies files?

If there's a `configure` script, try this:

    $ ./configure --prefix=$HOME/.local ...
                  ^-------------------^

Otherwise, try to uncomment and edit the relevant line in the `Makefile`, before
running `configure`.

Otherwise, set `PREFIX` both when compiling and when installing:

      v-----------------v
    $ PREFIX=$HOME/.local make
    $ PREFIX=$HOME/.local make install
      ^-----------------^

---

If you compile with `cmake(1)`, set the `CMAKE_INSTALL_PREFIX` variable:

            v-----------------------------------------v
    $ cmake -D CMAKE_INSTALL_PREFIX:PATH="$HOME/.local" ...
                                    ^--^
                                    variable type (like `BOOL`, `STRING`)

See: <https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html>

##
# CMake
## What is `-D`?

A `cmake(1)` flag which lets you create or update a CMake CACHE entry.
An entry is a couple `(variable name, value)`.
See `man cmake /^\s*-D\>`.

## What is `CMAKE_BUILD_TYPE`?

A `cmake(1)` variable:
<https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html>

Usually, you should  set it to `Release` because by  default, `cmake(1)` chooses
`RelWithDebInfo`, which might produce a bigger and slower binary:

   > In terms of compiler flags that usually means (since these are supported in most cases on all platforms anyway):
   >
   > 1. Release: `-O3 -DNDEBUG`
   > 2. Debug: `-O0 -g`
   > 3. RelWithDebInfo: `-O2 -g -DNDEBUG`
   > 4. MinSizeRel: `-Os -DNDEBUG`

Source: <https://stackoverflow.com/a/59314670>

In particular, you probably want `-O3`, not `-O2`.

##
# Debian packaging
## How to prevent my locally compiled package from being replaced by a standard one during `$ apt upgrade`?

Create a diversion with `dpkg-divert`, or have `aptitude(8)` hold the package.

Note that  `dpkg(1)` will respect  your diversion when  you try to  install your
newest  compiled version,  so  you might  want to  remove  the diversion  before
installing a new version of your custom compiled package.

For more info: <https://wiki.debian.org/apt-src#Ensuring_your_changes_persist>

###
## I have installed a standard package whose version is prefixed with `2:`.  What does that mean?

It's called the **epoch**:

   > This is a single (generally small) unsigned integer.
   > It may be omitted, in which case zero is assumed.
   > If it is omitted then the `upstream_version` may not contain any colons.
   > It  is provided  to  allow  mistakes in  the  version  numbers of  older
   > versions of a  package, and also a package's  previous version numbering
   > schemes, to be left behind.

Source: <https://serverfault.com/a/604549>

Example:

    $ aptitude search '?installed ?name(vim-tiny)' --display-format='%v'
    2:8.1.2269-1ubuntu5.14
    ^^

### What happens if I don't set that when I assign a version to my locally compiled package?

`0:` is assumed:

    0:X.Y.Z
    ^^

Now, suppose that you install a  package built locally with the version `4.5.6`,
while the official mirror contains the  same package with the version `2:1.2.3`.
When you'll  upgrade your system, your  local package will be  downgraded to the
one from the  official mirror, even though your version  is more recent.  That's
because the epoch is read first, and  your package's epoch is lower than the one
from the official mirror.
