# pyright: reportMissingImports=false
# pylint: disable=import-error,disable=too-many-arguments

# For examples of config:
# `~/VCS/kitty/kitty/tab_bar.py`
# https://github.com/kovidgoyal/kitty/discussions/4447

from os import getenv
import datetime
import sys

from kitty.fast_data_types import Screen
from kitty.rgb import Color
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, draw_title
from kitty.utils import color_as_int

debug = False
if debug:
    try:
        logfile = f'{getenv("TMPDIR")}/kitty_tab_bar.log'
        with open(logfile, 'w', encoding='utf-8') as fh:
            fh.write('message')
    except OSError:
        print(f'Failed to write: {logfile}')
        sys.exit()

    # What's this `dir()`?{{{
    #
    # A built-in function provided by the builtins module.
    # When  called without  an argument,  it returns  the list  of names  in the
    # current local scope.
    #
    # https://docs.python.org/3/library/functions.html#dir
    #
    # ---
    #
    # It's named like that after the name of the `DIR` command in DOS:
    # https://stackoverflow.com/a/48912069
    #
    # You can think of it as listing a "directory" of names.
    # Here, "directory" is meant to be read with original sense:
    #
    #    > a book listing individuals or organizations alphabetically or thematically
    #    > with details such as names, addresses, and phone numbers.
    #    > Synonyms: index, list, listing, register, catalog, record, archive, inventory
    #}}}
    # What's this `map()`?{{{
    #
    # A function provided by the builtins module.
    #
    #    > Return  an iterator  that  applies  function to  every  item of  iterable,
    #    > yielding  the  results. If  additional   iterable  arguments  are  passed,
    #    > function must  take that many arguments  and is applied to  the items from
    #    > all  iterables in  parallel. With multiple  iterables, the  iterator stops
    #    > when  the shortest  iterable is  exhausted. For cases  where the  function
    #    > inputs are already arranged into argument tuples, see itertools.starmap().
    #
    # Source: https://docs.python.org/3/library/functions.html#map
    #}}}
    attrs = '\n'.join(map(str, dir()))
    # List comprehension alternative:{{{
    #
    #     attrs = '\n'.join([str(i) for i in dir()])
    #}}}
    #   What's a list comprehension?{{{
    #
    #    > A compact way to  process all or part of the elements  in a sequence and
    #    > return a list with the results.
    #
    # Source: https://docs.python.org/3/glossary.html#term-list-comprehension
    #
    # Example:
    #
    #     >>> ['{:#04x}'.format(n) for n in range(16) if n % 2 == 0]
    #     ['0x00', '0x02', '0x04', '0x06', '0x08', '0x0a', '0x0c', '0x0e']
    #
    # This generates a list of strings containing even hex numbers (0x..) in the
    # range  from 0  to  16.  The  `if`  clause is  optional.   If omitted,  all
    # elements in `range(16)` are processed.
    #}}}
    #     In the last example, what's inside the square brackets?{{{
    #
    # A generator expression.
    # It returns an iterator.
    # Its syntax is:
    #
    #     expression for_clause if_clause
    #
    # The `for` clause defines  a loop variable and a range.
    # The `if` clause is optional; it lets you filter out arbitrary values given
    # by the previous `for`.
    # Its purpose is to generate values for an enclosing function.
    #
    #     >>> sum(n**2 for n in range(1, 10))
    #     285
    #
    # https://docs.python.org/3/glossary.html#term-generator-expression
    #
    # Note  that in  practice, passing  a list  comprehension to  a function  is
    # faster (and possibly more memory efficient):
    #
    #     >>> import timeit
    #
    #     >>> timeit.timeit('sum(n**2 for n in range(1, 100))', number = 100_000)
    #     2.4006554410007084
    #     ^^^
    #
    #                            v                           v
    #     >>> timeit.timeit('sum([n**2 for n in range(1, 100)])', number = 100_000)
    #     2.3176620090016513
    #     ^^^
    #}}}
    #       And what's this `'{:#04x}'.format(n)` ?{{{
    #
    # `.format()` is  a **method** which  lets you  format a string,  similar to
    # `printf()` in vimL.
    #
    # `'{:#04x}'` is the **format string**.
    #
    # `{:#04x}` is a **replacement field**.
    # A replacement field must be surrounded with curly brackets.
    # A format string can contain several replacement fields.
    #
    # `:` is a separator between the field name (which here is omitted), and the
    # **format specifier** (which here is `#04x`).
    #
    # `#` is an **option** causing the "**alternate form**" to be used for the conversion.
    # The meaning of the latter depends on the type of the conversion.
    # For integers, when  hexadecimal output is used, this option  adds the `0x`
    # prefix to the output value.
    #
    #     >>> print('{:x}'.format(123))
    #     7b
    #
    #                  v
    #     >>> print('{:#x}'.format(123))
    #     0x7b
    #     ^^
    #
    # In  `04`, `4`  stands for  the  **minimal field  width**, while  `0` is  a
    # **fill**  **character** which  pads the  field with  0s, if  the value  is
    # shorter than the field.
    #
    # Finally, in `#04x`, `x` is a **type of conversion**; here it stands for hex format.
    #}}}

    # What's an object?
    #
    # Any data with state (attributes or value) and defined behavior (methods).
    #
    # ---
    #
    # What's a sequence?
    #
    # An iterable which supports efficient  element access using integer indices
    # via the  `__getitem__()` special method  and defines a  `__len__()` method
    # that returns the length of  the sequence. Some built-in sequence types are
    # list, str, tuple, and bytes.
    #
    # Note  that dict  also  supports `__getitem__()`  and  `__len__()`, but  is
    # considered  a mapping  rather  than  a sequence  because  the lookups  use
    # arbitrary immutable keys rather than integers.
    #
    # https://docs.python.org/3/glossary.html#term-sequence
    #
    # ---
    #
    # What's an iterable?
    #
    # An object  capable of  returning its  members one  at a  time. Examples of
    # iterables include  all sequence types (such  as list, str, and  tuple) and
    # some  non-sequence types  like  dict,  file objects,  and  objects of  any
    # classes you define  with an `__iter__()` method or  with a `__getitem__()`
    # method that implements Sequence semantics.
    #
    # Iterables can  be used in a  `for` loop and  in many other places  where a
    # sequence is needed (zip(), map(), …).  When an iterable object is passed
    # as an argument  to the built-in function `iter()`, it  returns an iterator
    # for  the object.   This iterator  is good  for one  pass over  the set  of
    # values.   When  using iterables,  it  is  usually  not necessary  to  call
    # `iter()` or deal with iterator objects yourself.  The `for` statement does
    # that automatically for you, creating  a temporary unnamed variable to hold
    # the iterator for  the duration of the loop.
    #
    # ---
    #
    # What's a generator?
    #
    # ---
    #
    # What's a module?
    #
    # A Python file containing definitions which can be imported in:
    #
    #    - an arbitrary script (aka the main module)
    #    - other modules
    #    - an interactive instance of the interpreter
    #
    # There is no technical difference between a script and a module.
    # In particular, both can be executed and imported.
    # The difference comes from their purpose.
    # A script is meant to be executed; a module to be imported.
    #
    # ---
    #
    # What's a package?
    #
    # A Python module which can  contain submodules or recursively, subpackages.
    # Technically, a package is a Python module with a `__path__` attribute.
    # See also regular package and namespace package.
    #
    # ---
    #
    # What's a regular package?
    #
    # A traditional package, such as a directory containing an `__init__.py` file.
    #
    # ---
    #
    # What's a namespace package?
    #
    # A PEP 420 package which serves only as a container for subpackages.
    # Namespace packages  may have no physical  representation, and specifically
    # are not like a regular package because they have no `__init__.py` file.
    #
    # ---
    #
    # What's an iterator?
    #
    # An object representing a stream of data:
    #
    #     >>> l = [1, 2, 3]
    #     >>> it = iter(l)
    #     >>> it
    #     <list_iterator object at 0x7f1160ff9340>
    #
    # Repeated calls to  the iterator’s `__next__()` method (or  passing it to
    # the built-in function `next()`) return successive items in the stream:
    #
    #     >>> dir(it)
    #     [..., '__next__', ...]
    #     >>> it.__next__()
    #     1
    #     >>> it.__next__()
    #     2
    #     >>> it.__next__()
    #     3
    #
    # When  no more  data are  available a  `StopIteration` exception  is raised
    # instead.  At this point, the iterator  object is exhausted and any further
    # calls to its `__next__()` method just raise `StopIteration` again:
    #
    #     >>> it.__next__()
    #     Traceback (most recent call last):
    #       File "<stdin>", line 1, in <module>
    #     StopIteration
    #
    # Iterators are  required to  have an `__iter__()`  method that  returns the
    # iterator object itself.   The purpose is for every iterator  to be able to
    # be used in most places where other iterables are accepted:
    #
    #     >>> it = iter(l)
    #     >>> for n in it.__iter__():
    #     ...    n
    #     ...
    #     1
    #     2
    #     3
    #
    # However,  contrary to  other  iterables, an  iterator  cannot be  iterated
    # multiple  times.  That's  because  a  container object  (such  as a  list)
    # produces  a fresh  new iterator  each  time you  pass it  to the  `iter()`
    # function or use it in a `for` loop.
    # In  contrast, an  iterator will  just return  the same  exhausted iterator
    # object used in the previous iteration pass, making it appear like an empty
    # container:
    #
    #     >>> for n in it:
    #     ...    n
    #     ...
    #     ∅
    #
    # ---
    #
    # What's this `**`?
    #
    #     def parrot(voltage, state='a stiff', action='voom'):
    #         print("-- This parrot wouldn't", action, end=' ')
    #         print("if you put", voltage, "volts through it.", end=' ')
    #         print("E's", state, "!")
    #
    #     d = {"voltage": "four million", "state": "bleedin' demised", "action": "VOOM"}
    #     #     parrot(**d)
    #                  ^^
    #     # is it equivalent to this?
    #     parrot(voltage = 'four million', state = "bleedin' demised", action = 'VOOM')

    fh.write(attrs)
    fh.close()

# https://www.dummies.com/article/technology/programming-web-design/python/how-to-view-module-content-in-python-148324{{{
# dir(...)
#     dir([object]) -> list of strings
#
#     If called without an argument, return the names in the current scope.
#     Else, return an alphabetized list of names comprising (some of) the attributes
#     of the given object, and of attributes reachable from it.
#     If the object supplies a method named __dir__, it will be used; otherwise
#     the default dir() logic is used and returns:
#       for a module object: the module's attributes.
#       for a class object:  its attributes, and recursively the attributes
#         of its bases.
#       for any other object: its attributes, its class's attributes, and
#         recursively the attributes of its class's base classes.
#
# ---
#
#     Help on built-in function print in module builtins:
#
#     print(...)
#         print(value, ..., sep=' ', end='\n', file=sys.stdout, flush=False)
#
#         Prints the values to a stream, or to sys.stdout by default.
#         Optional keyword arguments:
#         file:  a file-like object (stream); defaults to the current sys.stdout.
#         sep:   string inserted between values, default a space.
#         end:   string appended after the last value, default a newline.
#         flush: whether to forcibly flush the stream.
#
# ---
#
# dir()
#
#     ['__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__spec__', 'datetime']
#}}}
# How to log all the imported objects?{{{
#
#}}}

def calc_draw_spaces(*args) -> int:
    length = 0
    for i in args:
        if not isinstance(i, str):
            i = str(i)
        length += len(i)
    return length


def _draw_icon(screen: Screen, index: int, symbol: str = ' study ') -> int:
    if index != 1:
        return None

    fg, bg = screen.cursor.fg, screen.cursor.bg
    screen.cursor.fg = 0
    screen.cursor.bg = as_rgb(color_as_int(Color(180, 145, 200)))
    screen.draw(symbol)
    screen.cursor.fg, screen.cursor.bg = fg, bg
    screen.cursor.x = len(symbol)
    return screen.cursor.x


def _draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    _: ExtraData,
) -> int:
    if draw_data.leading_spaces:
        screen.draw(' ' * draw_data.leading_spaces)
    draw_title(draw_data, screen, tab, index)
    trailing_spaces = min(max_title_length - 1, draw_data.trailing_spaces)
    max_title_length -= trailing_spaces
    extra = screen.cursor.x - before - max_title_length
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw('…')
    if trailing_spaces:
        screen.draw(' ' * trailing_spaces)
    end = screen.cursor.x
    screen.cursor.bold = screen.cursor.italic = False
    screen.cursor.fg = 0
    if not is_last:
        screen.cursor.bg = as_rgb(color_as_int(draw_data.inactive_bg))
        screen.draw(draw_data.sep)
    screen.cursor.bg = 0
    return end


def _draw_right_status(screen: Screen, is_last: bool) -> int:
    if not is_last:
        return None

    date = datetime.datetime.now().strftime(' %H:%M:%S ')

    right_status_length = calc_draw_spaces(date)

    draw_spaces = screen.columns - screen.cursor.x - right_status_length
    if draw_spaces > 0:
        screen.draw(' ' * draw_spaces)

    cells = [
        (Color(180, 145, 200), date),
    ]

    screen.cursor.fg = 0
    for color, status in cells:
        screen.cursor.bg = as_rgb(color_as_int(color))
        screen.draw(status)
    screen.cursor.bg = 0

    if screen.columns - screen.cursor.x > right_status_length:
        screen.cursor.x = screen.columns - right_status_length

    return screen.cursor.x


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    _draw_icon(screen, index, symbol=' study ')
    _draw_left_status(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    _draw_right_status(
        screen,
        is_last,
    )

    # necessary to be able to focus a tab by clicking on its title
    return screen.cursor.x
