# Inside a table, why should I never include a reference to itself via a syntax which operates in-place?

It's probably not what you want.

Suppose you write this:
```lua
a = {}
a.b = a
```
What is `a.b.b`?  Well, since `a.b` is `a`:

    a.b.b
    ^^^
     a

Then `a.b.b` is `a.b`, which is `a`.

Similarly, what is `a.b.b.b`?  Since, `a.b.b` is `a`:

    a.b.b.b
    ^---^
      a

Then `a.b.b.b` is `a.b`, which is still `a`.
No matter how many `.b` you append, `a.b.b.b...` is always `a`.

Lua does understand  this self-reference, which is why you  get this output when
you pretty print `a`:

    $ lua
    > a = {}
    > a.b = a
    > pp(a)
    <1>{
      b = <table 1>
    }

The same thing happens in Python:

    $ python
    >>> a = {}
    >>> a['b'] = a
    >>> print(b)
    {'b': {...}}
           ^^^

And in Vimscript:

    $ vim
    :let a = {} | let a.b = a | echo a
    {'b': {...}}
           ^^^

In Lua, the couple `<1>` and `<table 1>` are equivalent to the triple dot we can
find in other languages.

---

If you  want to expand a  table by including  its current value inside  a larger
table,  you can  use an  assignment on  the condition  that it  *overwrites* the
contents of the variable:

    $ lua
    > a = {}
    > a = { b = a }
    > pp(a)
    {
      b = {}
    }

This works as expected, because  the `a = { b = a }` assignment does not operate
in-place; it does  not alter the object currently assigned  to `a`.  Instead, it
overwrites its value.   OTOH, `a.b = a` does operate in-place; it  does alter an
existing object.
