# Functions
## In which order should the various kinds of parameters be declared in a function header?

   1. mandatory (aka non-default) parameters (`param`)
   2. optional (aka default) parameters (`param='value'`)
   3. parameter for variadic arguments (`*param`)
   4. parameter for variadic keyword arguments (`**param`)

---

Usually, mandatory parameters should come first.
You can't put optional parameters before:
```python
def func(optional=123, mandatory):
    pass
```
    SyntaxError: non-default argument follows default argument

Nor the parameter for variadic keyword arguments:
```python
def func(**kwargs, mandatory):
    pass
```
    SyntaxError: invalid syntax

---

The parameter for variadic keyword arguments must come last.
Nothing can come after.  Neither mandatory parameters:
```python
def func(**kwargs, mandatory):
    pass
```
    SyntaxError: invalid syntax

Nor optional parameters:
```python
def func(**kwargs, optional=0):
    pass
```
    SyntaxError: invalid syntax

Nor the parameter for variadic arguments:
```python
def func(**kwargs, *args):
    pass
```
    SyntaxError: invalid syntax

### Which exception to this order is allowed?

You  can  put  the  parameter   for  variadic  arguments  before  the  mandatory
parameters:
```python
def func(*args, mandatory):
    pass
```
But only in Python 3 (not in Python 2).
And if  you do  so, the mandatory  parameters can only  be assigned  via keyword
arguments (not positional ones):
```python
def func(*args, mandatory):
    pass

 #      ✘
 #      v
func(1, 2)
```
    TypeError: func() missing 1 required keyword-only argument: 'mandatory'
```python
def func(*args, mandatory):
    print(mandatory)

 #           ✔
 #      v---------v
func(1, mandatory=2)
```
    2

IOW,  you  can  only  move  the parameter  for  variadic  arguments  before  the
keyword-only parameters;  not before the positional-only  parameters, nor before
the positional-or-keyword parameters.

###
## How does Python assigns the arguments from a function call to the parameters in the function header?

First, it  assigns the positional  arguments (i.e. which  are not prefixed  by a
keyword, and which can be assigned to a non-variadic parameter).

Then, it assigns the keyword arguments  (i.e. which *are* prefixed by a keyword,
and which can be assigned to a non-variadic parameter).

Finally, all remaining non-keyword arguments –  if any – are assigned to the
parameter for variadic arguments (via a single tuple).
Similarly, all  remaining keyword arguments –  if any – are  assigned to the
parameter for variadic keyword arguments (via a single dictionary).

###
## When is a keyword argument necessary?

Obviously, you have to use a keyword argument to assign a keyword-only parameter
(i.e. a  parameter which is declared  after the special parameter  `*`, or after
the parameter for variadic arguments).

But you might also need one when you want to skip over some optional argument(s)
in a function call.

For example, suppose a function accepts  2 optional arguments, and in a function
call you need to pass a value for  the 2nd argument, but not for the 1st (you're
OK with its default value).  If you want  to skip the latter, you need a keyword
argument:
```python
def my_function(opt1=12, opt2=34):
    print(opt1, opt2)

my_function(opt2=56)
 #          ^-----^
```
    12 56

Without,  you would  have  to specify  the  default value  of  the 1st  optional
argument in the function call:
```python
def my_function(opt1=12, opt2=34):
    print(opt1, opt2)

my_function(12, 56)
 #          ^^
```
### When should I use one (even if not stricly required)?

Whenever its meaning is not easy to understand from the context.
The context being the name of the function, and the position of the argument.

##
# Miscellaneous
## How does Python compute an integer division, where one of the operands is negative?

The result is rounded down:
```python
print(-7 // 4)
```
    -2

If you prefer the result to be rounded up (i.e. the fractional to be discarded),
use the `int()` function:
```python
print(int(-7 / 4))
```
    -1

Notice that this time, we used the `/` operator, instead of `//`.
The former  returns the *algebraic* quotient  of its operands, while  the latter
returns the *floored* quotient of its operands.

## How is a floating point number stored internally?

It's  represented according  to the  IEEE 754  double-precision binary  floating
point  format, which  is stored  in 64  bits of  information divided  into three
sections: sign, exponent, and mantissa.

## When should I encode a string object into a bytes object?

When you want to store textual data in a file, or send it on the network.

## What's the order of the items in a dictionary??

Dictionary order is guaranteed to be insertion order since Python 3.7.
That  is, the  order  in which  the  items  were added  into  the dictionary  is
preserved.

Before 3.7, it's random.

## What's the difference between a script and a module?

A module is meant to be imported.  A script is meant to be executed.
A module is compiled under `__pycache__/`, not a script.

##
## What's the difference between the ranges `[a, b]`, `(a, b)`, `[a, b)`, `(a, b]`?

First, this assumes that  an order is defined on the set  of elements "from" `a`
"to" `b`, whatever `a` and `b` are.

When `a` or `b` is next to a square bracket, it's included inside the range.
When `a` or `b` is next to an open bracket, it's excluded from the range.

With these rules, we can interpret the previous ranges like so:

    ┌──────────┬───────────────────────────────────────────┐
    │ notation │                  meaning                  │
    ├──────────┼───────────────────────────────────────────┤
    │ [a, b]   │ from a to b, a and b are included         │
    ├──────────┼───────────────────────────────────────────┤
    │ (a, b)   │ from a to b, a and b are excluded         │
    ├──────────┼───────────────────────────────────────────┤
    │ [a, b)   │ from a to b, a is included, b is excluded │
    ├──────────┼───────────────────────────────────────────┤
    │ (a, b]   │ from a to b, a is excluded, b is included │
    └──────────┴───────────────────────────────────────────┘

### Why is `[a, b)` particularly useful?

It lets you split a range into multiple sub-ranges.
Conversely, it lets you concatenate multiple sub-ranges into a single range.

For example, `[a, b)` can be split into 4 sub-ranges like this:

    [a, b) = [a, k₁) + [k₁, k₂) + [k₂, k₃) + [k₃, b)

Since  the  items  where  we  split  the  range  (`k₁`,  `k₂`,  `k₃`)  are
alternatively excluded and  included when used resp.  as the end and  start of a
sub-range, they're  included exactly once in  the final result.  If  we used `]`
instead of  `)`, they  would be  included twice.   But inside  `[a, b)`, they're
present only once; so we need them once, not twice.
