# Why should I never install Python in `/usr/local/bin/`?

It might break some tools.

From the `dpkg` IRC bot:

         │ !local python
    dpkg │ An installation of python in /usr/local/bin/ is a great way of breaking a great many tools in Debian,
         │ which assume running "python" runs the Debian python with the installed python modules.  Removing
         │ /usr/local/bin/python* should be enough to fix the problem; if you really need your own local version of
         │ system tools like python (and perl, and ...) make sure they are not on $PATH when you are performing
         │ upgrades. Ask me about <virtualenv>

OTOH, it should be OK in `~/.local/bin/`,  because the latter is not in the PATH
of a root process.

# Why should I never install a library inside `~/.local/`?

It's hard  to remove, because  you don't know  which application (e.g.  tldr) or
script (e.g. interSubs) depends on it.

---

It's also hard to manage,  because you might have different applications/scripts
which have  incompatible requirements.  For  example, you might want  to install
the application `foo` which depends  on `baz < 12.34`, and the application `bar`
which depends on `baz > 12.34`.

---

Finally, it can override a dependency  used by a system-wide application; and if
the overriding  version does not match  the one required by  the application, it
will probably break the latter.

To  illustrate how  a library  in `~/.local`  can be  imported by  a system-wide
binary:

    # on Ubuntu 20.04
    $ sudo apt install screenkey
    $ python3 -m pip install --user --upgrade git+https://gitlab.com/screenkey/screenkey
    $ /usr/bin/screenkey --version
    1.5
    $ sudo /usr/bin/screenkey --version
    0.9

Notice that `/usr/bin/screenkey`  does not report the same  version depending on
whether it runs as  the root user.  That's because when run  as a non-root user,
it can import libraries from `~/.local/lib/python3.8/site-packages/`:

    $ python3 -c 'import sys; print(sys.path)'
    [..., '/home/lgc/.local/lib/python3.8/site-packages', ...]

That's unexpected.  It should report 0.9 because that's the version installed by
the Debian package.

# Why should I never surround the name of one of my functions/methods with dunderscores?

Python uses this convention to name magic methods.

If  you use  the  same convention  for  your own  methods, there  is  a risk  of
collision; e.g. you might accidentally  overwrite the definition of an important
method, causing unexpected results.

Leave this naming convention to the devs.

# Why should I surround a complex number with parens before asking for its imaginary part?

Without parens, the real part would be added to the imaginary part.
That's because there is an ambiguity in this expression:

    1+2j.imag

Are you asking for the imaginary of `1+2j`?
Or are you asking for `1` to be added to the imaginary of `2j`?

Without parens,  Python uses  the latter interpretation,  which is  probably not
what you want.  That's why you need parens:

    (1+2j).imag
    ^    ^

---

The same ambiguity applies to the  `real` attribute.  However, you still get the
correct result even if  you omit the parens.  That's because the  real part of a
pure imaginary  number is by  definition 0;  so Python adds  the real part  to 0
which leaves the real part unchanged.

Same thing for the conjugate.  There is an ambiguity, but it doesn't matter:

    1+2j.conjugate()

Nevertheless, to be consistent and readable,  always use parens around a complex
number for which you ask an attribute or invoke a method, even when not strictly
necessary:

    v    v
    (1+2j).real
    (1+2j).imag
    (1+2j).conjugate()
    ^    ^

# Why are some objects printed differently depending on whether I use `print()` or not in an interactive Python shell?

Because by default, Python prints the canonical representation of an object (see
`pydoc repr`).

    >>> from fractions import Fraction as F

    >>> F(10, 6)
    Fraction(5, 3)

    >>> print(Fraction(10, 6))
    5/3


    >>> str = """This is
    a multiline string."""

    >>> str
    'This is\na multiline string.'

    >>> print(str)
    This is
    a multiline string.

Such a  representation can be used  to completely reconstruct the  object, using
the `eval()` function:

    >>> from fractions import Fraction
    >>> eval(repr(Fraction(10, 6)))
    Fraction(5, 3)

##
# Mutability
## These snippets give different results:
```python
a = [1]
b = a
b = b + [2]
print(a, b)
```
    [1] [1, 2]
```python
a = [1]
b = a
b += [2]
print(a, b)
```
    [1, 2] [1, 2]
      ^^^

### Why?

The second snippet uses an augmented assignment instead of a simple one:

    b += [2]

In an augmented assignment, if the name in the LHS is bound to a mutable object,
then the operation is performed in-place.

##
## Why should I avoid a mutable object for the default value of an optional parameter?

It would mutate across function calls which is probably not what you want:
```python
def func(opt=[]):
    opt.append(0)
    print(opt)

func()
func()
func()
```
    [0]
    [0, 0]
    [0, 0, 0]

If `opt` had always been assigned the  default value `[]`, then the output would
always have been the same:

    [0]
    [0]
    [0]

But that's not  what happened.  During the first call,  `opt` has correctly been
assigned `[]`,  hence why  the function  prints `[0]` after  the item  `"x"` was
added.  But during the subsequent calls, `opt` has *not* been assigned `[]`.

---

This is an issue for lists and dictionaries; not for tuples which are immutable.

### But why does that happen?  Why is the default value sometimes ignored?

Because it's not  assigned on each function call.  It's  just used to initialize
an attribute of the function object when the latter is created:
```python
def func(a=[], b={}):
    a.append(len(a))
    b[len(a)] = len(a)

print(func.__defaults__)

func()
print(func.__defaults__)

func()
print(func.__defaults__)

func()
print(func.__defaults__)
```
    ([], {})
    ([0], {1: 1})
    ([0, 1], {1: 1, 2: 2})
    ([0, 1, 2], {1: 1, 2: 2, 3: 3})

Notice  how  the  default values  are  bound  to  the  function object  via  its
`__defaults__` attribute which  holds all of them inside a  single tuple.  Also,
notice how after each function call, the items inside `__defaults__` mutate.

IOW, the default value is only used at definition time; not at call time.

### OK.  And how do I work around that?

First, use `None` as the default value.   Then, in the function body, assign the
default value to the optional parameter if, and only if, it's `None`.
```python
 #           v--v
def func(opt=None):
    #      v-----v
    if opt is None:
        opt = []
    opt.append(0)
    print(opt)

func()
func()
func()
```
    [0]
    [0]
    [0]

##
# Why should I avoid `from module import *`?

It makes it hard:

   - to avoid conflicting names
   - to find where an imported item is defined

   - to know which items are imported (in particular, if you're in A, and import
     module B, which itself imports another module C, C will be imported in A)

   - for  the  editor to  provide  extra  features such  as  code completion,
     go-to definition, and inline documentation
