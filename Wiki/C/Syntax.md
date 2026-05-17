# How do strings work in C?

C  concatenates  string  literals  if  they  are  separated  by  nothing  or  by
whitespace.

For example:

     char[50] = "Hello, and"" how are"  " you"
             " today!";

is equivalent to this:

     char greeting[50] = "Hello, and how are you today!";

---

If  you want  to  use a  double  quotation  mark within  a  string, precede  the
quotation mark with a backslash.

---

Character string constants are placed in the "static storage" class, which means
that if you use a string constant in  a function, the string is stored just once
and  lasts for  the duration  of the  program, even  if the  function is  called
several times.

---

A  string acts  as a  pointer to  where the  string is  stored.  This  action is
analogous to the name of an array acting as a pointer to the array’s location.

---

    const char s[15] = "I am a string."

is short for the standard initialization form:

    const char s[15] = {'I', ' ', 'a', 'm', ' ',
    'a', ' ', 's', 't', 'r', 'i', 'n', 'g', '.', '\0'};

---

When you specify the array size, be sure that the number of elements is at least
one more than the string length (for the trailing null character).

---

Any unused elements are automatically initialized  to 0 (which in `char` form is
the null character, not the zero digit character):

     const char pets[12] = "nice cat."
     ⇔
     n i c e  c a t . \0\0\0
                      ^----^
                      extra elements initialized to NULL

Or, just let the compiler determine the array size:

    const char pets[] = "nice cat."
                   ^^

String-related functions  typically don't need  to know  the size of  the array,
because they can simply look for the null character to mark the end.

Obviously, you can  omit the size only if you  initialize the array immediately.
If you create  an array you intend to  fill later, you need to  specify the size
when you declare it.

The size of  a `char` array must  be a constant (including  an expression formed
from constant integer values).  Starting from C99, it can be a variable (VLA).

# What's the difference between `const char * ptr = "..."` and `char array[] = "..."`?

With the array form  (`array[]`), the quoted string is stored  in a data segment
that is part of the executable file;  when the program is loaded into memory, so
is that string.   The quoted string is  said to be in "static  memory".  But the
memory for  the array is  allocated only after  the program begins  running.  At
that time, the quoted string is copied into the array.  Note that, at this time,
there are two copies of the string.  One is the string literal in static memory,
and one is the string stored in `array`.

---

The compiler will recognize the name `array` as a synonym for the address of the
first array  element, `&array[0]`.  Thus,  `array` is an address  constant.  You
can't change `array`  as a whole, because that would  mean changing the location
(address) where the  array is stored.  You can use  operations such as `array+1`
to identify  the next element  in an array, but  `++array` is not  allowed.  The
increment  operator can  be used  only  with the  names of  variables (or,  more
generally, modifiable lvalues), not with constants.

---

The pointer  form (`* ptr`)  also causes  elements in static  storage to  be set
aside for the  string.  In addition, once the program  begins execution, it sets
aside one  more storage location for  the pointer variable `ptr`  and stores the
address of the  string in the pointer variable.  This  variable initially points
to the first character of the string,  but the value can be changed.  Therefore,
you can  use the increment operator.   For instance, `++ptr` would  point to the
second character.

---

In short,  initializing the  array copies  a string from  static storage  to the
array, whereas initializing the pointer merely copies the address of the string.

---

A string  literal is considered  to be `const` data.   Hence why you  should use
the  `const` qualifier  with `char * ptr`.   There's  no need  for `const`  with
`char array[]`, because  in that case  the string is merely  a copy of  a string
literal (but you can if you want to).

You can't change the string via `ptr`,  but you can change where `ptr` points to
(provided you didn't use `const` right before `ptr`).  For example:

    // make `ptr` points to the 2nd character of the string
    ptr++;

You *can*  change the string  via `array`  (provided you didn't  use `const`).
For example:

    // replace first character with an `X`
    array[0] = 'X';
